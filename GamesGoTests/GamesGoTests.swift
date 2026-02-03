import Testing
import Foundation
import SwiftData
@testable import GamesGo

@MainActor
@Suite(.serialized)
struct GamesGoTests {
    private func makeRepository() throws -> (GameRepository, ModelContainer) {
        let config = ModelConfiguration(
            UUID().uuidString,
            isStoredInMemoryOnly: true
        )
        let container = try ModelContainer(for: Game.self, configurations: config)
        let repository = GameRepository(modelContext: container.mainContext)
        return (repository, container)
    }

    @Test func emptyRepositoryHasNoGames() throws {
        let (repository, container) = try makeRepository()
        #expect(!repository.hasGames())
        withExtendedLifetime(container) {}
    }

    @Test func repositoryInsertAndFetch() throws {
        let (repository, container) = try makeRepository()

        #expect(!repository.hasGames())

        let dto = MockData.makeSampleDTO()
        try repository.insertGames([dto])

        #expect(repository.hasGames())
        let games = try repository.allActiveGames()
        #expect(games.count == 1)
        #expect(games[0].title == "Dauntless")
        withExtendedLifetime(container) {}
    }

    @Test func repositoryInsertMultipleDTOs() throws {
        let (repository, container) = try makeRepository()

        let dtos = try JSONDecoder().decode([GameDTO].self, from: MockData.sampleJSON)
        try repository.insertGames(dtos)

        let games = try repository.allActiveGames()
        #expect(games.count == 3)
        withExtendedLifetime(container) {}
    }

    @Test func repositorySoftDelete() throws {
        let (repository, container) = try makeRepository()

        let dto = MockData.makeSampleDTO()
        try repository.insertGames([dto])

        let games = try repository.allActiveGames()
        try repository.softDelete(games[0])

        let activeGames = try repository.allActiveGames()
        #expect(activeGames.isEmpty)
        #expect(repository.hasGames())
        withExtendedLifetime(container) {}
    }

    @Test func softDeleteOnlyAffectsTargetGame() throws {
        let (repository, container) = try makeRepository()

        let dtos = try JSONDecoder().decode([GameDTO].self, from: MockData.sampleJSON)
        try repository.insertGames(dtos)

        let games = try repository.allActiveGames()
        try repository.softDelete(games[0])

        let activeGames = try repository.allActiveGames()
        #expect(activeGames.count == 2)
        withExtendedLifetime(container) {}
    }

    @Test func allActiveGamesAreSortedByTitle() throws {
        let (repository, container) = try makeRepository()

        let dtos = try JSONDecoder().decode([GameDTO].self, from: MockData.sampleJSON)
        try repository.insertGames(dtos)

        let games = try repository.allActiveGames()
        let titles = games.map(\.title)
        #expect(titles == titles.sorted())
        withExtendedLifetime(container) {}
    }

    @Test func saveChangesPreservesData() throws {
        let (repository, container) = try makeRepository()

        let dto = MockData.makeSampleDTO()
        try repository.insertGames([dto])

        let games = try repository.allActiveGames()
        games[0].userNotes = "Updated note"
        try repository.saveChanges()

        let fetched = try repository.allActiveGames()
        #expect(fetched[0].userNotes == "Updated note")
        withExtendedLifetime(container) {}
    }

    @Test func insertEmptyArrayDoesNotCrash() throws {
        let (repository, container) = try makeRepository()
        try repository.insertGames([])
        #expect(!repository.hasGames())
        withExtendedLifetime(container) {}
    }
}
