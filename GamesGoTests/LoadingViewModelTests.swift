import Testing
import Foundation
import SwiftData
@testable import GamesGo

@MainActor
@Suite(.serialized)
struct LoadingViewModelTests {
    private func makeEnvironment(
        mockResult: Result<[GameDTO], Error> = .success([])
    ) throws -> (LoadingViewModel, MockNetworkService, ModelContainer) {
        let config = ModelConfiguration(
            UUID().uuidString,
            isStoredInMemoryOnly: true
        )
        let container = try ModelContainer(for: Game.self, configurations: config)
        let repository = GameRepository(modelContext: container.mainContext)
        let mockService = MockNetworkService()
        mockService.result = mockResult
        let vm = LoadingViewModel(networkService: mockService, repository: repository)
        return (vm, mockService, container)
    }

    @Test func needsDownloadWhenEmpty() throws {
        let (vm, _, container) = try makeEnvironment()
        #expect(vm.needsDownload == true)
        withExtendedLifetime(container) {}
    }

    @Test func doesNotNeedDownloadWhenDataExists() throws {
        let config = ModelConfiguration(
            UUID().uuidString,
            isStoredInMemoryOnly: true
        )
        let container = try ModelContainer(for: Game.self, configurations: config)
        let repository = GameRepository(modelContext: container.mainContext)
        try repository.insertGames([MockData.makeSampleDTO()])

        let vm = LoadingViewModel(networkService: MockNetworkService(), repository: repository)
        #expect(vm.needsDownload == false)
        withExtendedLifetime(container) {}
    }

    @Test func downloadCatalogSuccess() async throws {
        let dtos = try JSONDecoder().decode([GameDTO].self, from: MockData.sampleJSON)
        let (vm, _, container) = try makeEnvironment(mockResult: .success(dtos))

        #expect(vm.isLoading == true)
        await vm.downloadCatalog()

        #expect(vm.isLoading == false)
        #expect(vm.errorMessage == nil)
        #expect(vm.needsDownload == false)
        withExtendedLifetime(container) {}
    }

    @Test func downloadCatalogFailure() async throws {
        let (vm, _, container) = try makeEnvironment(
            mockResult: .failure(NetworkError.badResponse)
        )

        await vm.downloadCatalog()

        #expect(vm.isLoading == false)
        #expect(vm.errorMessage != nil)
        #expect(vm.needsDownload == true)
        withExtendedLifetime(container) {}
    }

    @Test func downloadCatalogResetsErrorOnRetry() async throws {
        let (vm, mockService, container) = try makeEnvironment(
            mockResult: .failure(NetworkError.badResponse)
        )

        await vm.downloadCatalog()
        #expect(vm.errorMessage != nil)

        let dtos = [MockData.makeSampleDTO()]
        mockService.result = .success(dtos)
        await vm.downloadCatalog()

        #expect(vm.errorMessage == nil)
        #expect(vm.isLoading == false)
        withExtendedLifetime(container) {}
    }

    @Test func initialState() throws {
        let (vm, _, container) = try makeEnvironment()
        #expect(vm.isLoading == true)
        #expect(vm.errorMessage == nil)
        withExtendedLifetime(container) {}
    }
}
