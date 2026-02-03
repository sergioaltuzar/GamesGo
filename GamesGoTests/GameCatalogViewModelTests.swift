import Testing
import Foundation
import SwiftData
@testable import GamesGo

@MainActor
@Suite(.serialized)
struct GameCatalogViewModelTests {
    private func makeViewModel() throws -> (GameCatalogViewModel, ModelContainer) {
        let config = ModelConfiguration(
            UUID().uuidString,
            isStoredInMemoryOnly: true
        )
        let container = try ModelContainer(for: Game.self, configurations: config)
        let context = container.mainContext
        let repository = GameRepository(modelContext: context)

        let game1 = Game(apiId: 1, title: "Dauntless", thumbnailURL: "", shortDescription: "RPG game", gameURL: "", genre: "MMORPG", platform: "PC", publisher: "PL", developer: "PL", releaseDate: "2019-05-21", freetogameProfileURL: "")
        let game2 = Game(apiId: 2, title: "World of Tanks", thumbnailURL: "", shortDescription: "Shooter game", gameURL: "", genre: "Shooter", platform: "PC", publisher: "WG", developer: "WG", releaseDate: "2011-04-12", freetogameProfileURL: "")
        let game3 = Game(apiId: 3, title: "Genshin Impact", thumbnailURL: "", shortDescription: "Open world", gameURL: "", genre: "RPG", platform: "PC", publisher: "mHY", developer: "mHY", releaseDate: "2020-09-28", freetogameProfileURL: "")

        context.insert(game1)
        context.insert(game2)
        context.insert(game3)
        try context.save()

        let vm = GameCatalogViewModel(repository: repository)
        vm.loadGames()
        return (vm, container)
    }

    @Test func filteredGamesByGenre() throws {
        let (vm, container) = try makeViewModel()
        vm.selectedGenre = "Shooter"
        #expect(vm.filteredGames.count == 1)
        #expect(vm.filteredGames[0].title == "World of Tanks")
        withExtendedLifetime(container) {}
    }

    @Test func filteredGamesBySearchText() throws {
        let (vm, container) = try makeViewModel()
        vm.searchText = "Genshin"
        #expect(vm.filteredGames.count == 1)
        #expect(vm.filteredGames[0].title == "Genshin Impact")
        withExtendedLifetime(container) {}
    }

    @Test func combinedGenreAndSearchFilter() throws {
        let (vm, container) = try makeViewModel()
        vm.selectedGenre = "MMORPG"
        vm.searchText = "Daunt"
        #expect(vm.filteredGames.count == 1)
        withExtendedLifetime(container) {}
    }

    @Test func genresListIncludesAll() throws {
        let (vm, container) = try makeViewModel()
        #expect(vm.genres.first == GenreConstants.allGenresLabel)
        #expect(vm.genres.count == 4) // All + MMORPG + RPG + Shooter
        withExtendedLifetime(container) {}
    }

    @Test func allGenresShowsAllGames() throws {
        let (vm, container) = try makeViewModel()
        vm.selectedGenre = GenreConstants.allGenresLabel
        #expect(vm.filteredGames.count == 3)
        withExtendedLifetime(container) {}
    }

    @Test func suggestionsReturnMatchingTitles() throws {
        let (vm, container) = try makeViewModel()
        vm.searchText = "World"
        #expect(vm.suggestions.contains("World of Tanks"))
        withExtendedLifetime(container) {}
    }

    @Test func suggestionsEmptyWhenNoSearch() throws {
        let (vm, container) = try makeViewModel()
        vm.searchText = ""
        #expect(vm.suggestions.isEmpty)
        withExtendedLifetime(container) {}
    }

    @Test func searchByGenreName() throws {
        let (vm, container) = try makeViewModel()
        vm.searchText = "Shooter"
        #expect(vm.filteredGames.count == 1)
        #expect(vm.filteredGames[0].title == "World of Tanks")
        withExtendedLifetime(container) {}
    }
}
