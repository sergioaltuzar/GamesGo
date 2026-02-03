import Testing
import Foundation
@testable import GamesGo

struct NetworkServiceTests {
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

    @Test func networkErrorDescriptions() {
        #expect(NetworkError.invalidURL.errorDescription == "Invalid URL")
        #expect(NetworkError.badResponse.errorDescription == "Server response error")
        #expect(NetworkError.decodingFailed.errorDescription == "Failed to process data")
    }
}
