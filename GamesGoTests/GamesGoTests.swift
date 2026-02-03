import Testing
import SwiftData
@testable import GamesGo

@MainActor
struct GamesGoTests {
    @Test func modelContainerCreation() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Game.self, configurations: config)
        #expect(container.mainContext != nil)
    }

    @Test func repositoryInsertAndFetch() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Game.self, configurations: config)
        let repository = GameRepository(modelContext: container.mainContext)

        #expect(!repository.hasGames())

        let dto = MockData.makeSampleDTO()
        try repository.insertGames([dto])

        #expect(repository.hasGames())
        let games = try repository.allActiveGames()
        #expect(games.count == 1)
        #expect(games[0].title == "Dauntless")
    }

    @Test func repositorySoftDelete() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Game.self, configurations: config)
        let repository = GameRepository(modelContext: container.mainContext)

        let dto = MockData.makeSampleDTO()
        try repository.insertGames([dto])

        let games = try repository.allActiveGames()
        try repository.softDelete(games[0])

        let activeGames = try repository.allActiveGames()
        #expect(activeGames.isEmpty)
    }
}
