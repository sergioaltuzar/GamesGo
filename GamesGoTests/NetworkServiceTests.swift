import Testing
import Foundation
@testable import GamesGo

@Suite(.serialized)
struct NetworkServiceTests {

    // MARK: - MockURLProtocol

    private final class MockURLProtocol: URLProtocol, @unchecked Sendable {
        nonisolated(unsafe) static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

        override class func canInit(with request: URLRequest) -> Bool { true }
        override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

        override func startLoading() {
            guard let handler = MockURLProtocol.requestHandler else {
                client?.urlProtocolDidFinishLoading(self)
                return
            }
            do {
                let (response, data) = try handler(request)
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                client?.urlProtocol(self, didLoad: data)
                client?.urlProtocolDidFinishLoading(self)
            } catch {
                client?.urlProtocol(self, didFailWithError: error)
            }
        }

        override func stopLoading() {}
    }

    private func makeService() -> NetworkService {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return NetworkService(session: URLSession(configuration: config))
    }

    // MARK: - Real NetworkService tests

    @Test func fetchGamesSuccess() async throws {
        let service = makeService()
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, MockData.sampleJSON)
        }

        let games = try await service.fetchGames()
        #expect(games.count == 3)
        #expect(games[0].title == "Dauntless")
        #expect(games[1].title == "World of Tanks")
        #expect(games[2].title == "Genshin Impact")
    }

    @Test func fetchGamesServerError() async {
        let service = makeService()
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }

        await #expect(throws: NetworkError.self) {
            try await service.fetchGames()
        }
    }

    @Test func fetchGames404Error() async {
        let service = makeService()
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 404,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }

        await #expect(throws: NetworkError.self) {
            try await service.fetchGames()
        }
    }

    @Test func fetchGamesInvalidJSON() async {
        let service = makeService()
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            let badData = "not json".data(using: .utf8)!
            return (response, badData)
        }

        await #expect(throws: (any Error).self) {
            try await service.fetchGames()
        }
    }

    @Test func fetchGamesEmptyArray() async throws {
        let service = makeService()
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            let data = "[]".data(using: .utf8)!
            return (response, data)
        }

        let games = try await service.fetchGames()
        #expect(games.isEmpty)
    }

    // MARK: - Mock service tests

    @Test func mockServiceReturnsData() async throws {
        let mockService = MockNetworkService()
        let dto = MockData.makeSampleDTO()
        mockService.result = .success([dto])

        let games = try await mockService.fetchGames()
        #expect(games.count == 1)
        #expect(games[0].title == "Dauntless")
    }

    @Test func mockServiceThrowsError() async {
        let mockService = MockNetworkService()
        mockService.result = .failure(NetworkError.badResponse)

        await #expect(throws: NetworkError.self) {
            try await mockService.fetchGames()
        }
    }

    // MARK: - Error descriptions

    @Test func networkErrorDescriptions() {
        #expect(NetworkError.invalidURL.errorDescription == "Invalid URL")
        #expect(NetworkError.badResponse.errorDescription == "Server response error")
        #expect(NetworkError.decodingFailed.errorDescription == "Failed to process data")
    }

    @Test func networkErrorConformsToLocalizedError() {
        let error: LocalizedError = NetworkError.badResponse
        #expect(error.errorDescription != nil)
    }
}
