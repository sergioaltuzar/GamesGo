import Testing
import Foundation
import SwiftData
@testable import GamesGo

@MainActor
@Suite(.serialized)
struct GameDetailViewModelTests {
    private func makeViewModel() throws -> (GameDetailViewModel, Game, ModelContainer) {
        let config = ModelConfiguration(
            UUID().uuidString,
            isStoredInMemoryOnly: true
        )
        let container = try ModelContainer(for: Game.self, configurations: config)
        let context = container.mainContext
        let repository = GameRepository(modelContext: context)

        let game = Game(apiId: 1, title: "Test Game", thumbnailURL: "", shortDescription: "Desc", gameURL: "", genre: "RPG", platform: "PC", publisher: "Pub", developer: "Dev", releaseDate: "2024-01-01", freetogameProfileURL: "")
        context.insert(game)
        try context.save()

        let vm = GameDetailViewModel(game: game, repository: repository)
        return (vm, game, container)
    }

    @Test func saveNotesUpdatesGame() throws {
        let (vm, game, container) = try makeViewModel()
        vm.userNotes = "My custom note"
        vm.saveNotes()
        #expect(game.userNotes == "My custom note")
        withExtendedLifetime(container) {}
    }

    @Test func deleteGameSetsIsRemoved() throws {
        let (vm, game, container) = try makeViewModel()
        vm.deleteGame()
        #expect(game.isRemoved == true)
        #expect(vm.didDelete == true)
        withExtendedLifetime(container) {}
    }

    @Test func initialNotesMatchGame() throws {
        let (vm, game, container) = try makeViewModel()
        #expect(vm.userNotes == game.userNotes)
        withExtendedLifetime(container) {}
    }

    @Test func initialStateIsCorrect() throws {
        let (vm, _, container) = try makeViewModel()
        #expect(vm.showDeleteConfirmation == false)
        #expect(vm.didDelete == false)
        #expect(vm.userNotes == "")
        withExtendedLifetime(container) {}
    }

    @Test func saveEmptyNotes() throws {
        let (vm, game, container) = try makeViewModel()
        vm.userNotes = "Some text"
        vm.saveNotes()
        #expect(game.userNotes == "Some text")

        vm.userNotes = ""
        vm.saveNotes()
        #expect(game.userNotes == "")
        withExtendedLifetime(container) {}
    }

    @Test func deleteDoesNotAffectNotesSync() throws {
        let (vm, _, container) = try makeViewModel()
        vm.userNotes = "Note before delete"
        vm.deleteGame()
        #expect(vm.didDelete == true)
        #expect(vm.userNotes == "Note before delete")
        withExtendedLifetime(container) {}
    }

    @Test func deletedGameNotInActiveList() throws {
        let config = ModelConfiguration(
            UUID().uuidString,
            isStoredInMemoryOnly: true
        )
        let container = try ModelContainer(for: Game.self, configurations: config)
        let context = container.mainContext
        let repository = GameRepository(modelContext: context)

        let game = Game(apiId: 1, title: "To Delete", thumbnailURL: "", shortDescription: "", gameURL: "", genre: "RPG", platform: "PC", publisher: "", developer: "", releaseDate: "", freetogameProfileURL: "")
        context.insert(game)
        try context.save()

        let vm = GameDetailViewModel(game: game, repository: repository)
        vm.deleteGame()

        let activeGames = try repository.allActiveGames()
        #expect(activeGames.isEmpty)
        withExtendedLifetime(container) {}
    }
}
