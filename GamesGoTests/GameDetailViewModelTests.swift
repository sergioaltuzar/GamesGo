import Testing
import Foundation
import SwiftData
@testable import GamesGo

@MainActor
struct GameDetailViewModelTests {
    private func makeViewModel() throws -> (GameDetailViewModel, Game) {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Game.self, configurations: config)
        let context = container.mainContext
        let repository = GameRepository(modelContext: context)

        let game = Game(apiId: 1, title: "Test Game", thumbnailURL: "", shortDescription: "Desc", gameURL: "", genre: "RPG", platform: "PC", publisher: "Pub", developer: "Dev", releaseDate: "2024-01-01", freetogameProfileURL: "")
        context.insert(game)
        try context.save()

        let vm = GameDetailViewModel(game: game, repository: repository)
        return (vm, game)
    }

    @Test func saveNotesUpdatesGame() throws {
        let (vm, game) = try makeViewModel()
        vm.userNotes = "My custom note"
        vm.saveNotes()
        #expect(game.userNotes == "My custom note")
    }

    @Test func deleteGameSetsIsDeleted() throws {
        let (vm, game) = try makeViewModel()
        vm.deleteGame()
        #expect(game.isDeleted == true)
        #expect(vm.didDelete == true)
    }

    @Test func initialNotesMatchGame() throws {
        let (vm, game) = try makeViewModel()
        #expect(vm.userNotes == game.userNotes)
    }
}
