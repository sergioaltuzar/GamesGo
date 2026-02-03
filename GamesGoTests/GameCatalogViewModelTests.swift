import Testing
import Foundation
import SwiftData
@testable import GamesGo

@MainActor
struct GameCatalogViewModelTests {
    private func makeViewModel() throws -> GameCatalogViewModel {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
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
        return vm
    }

    @Test func filteredGamesByGenre() throws {
        let vm = try makeViewModel()
        vm.selectedGenre = "Shooter"
        #expect(vm.filteredGames.count == 1)
        #expect(vm.filteredGames[0].title == "World of Tanks")
    }

    @Test func filteredGamesBySearchText() throws {
        let vm = try makeViewModel()
        vm.searchText = "Genshin"
        #expect(vm.filteredGames.count == 1)
        #expect(vm.filteredGames[0].title == "Genshin Impact")
    }

    @Test func combinedGenreAndSearchFilter() throws {
        let vm = try makeViewModel()
        vm.selectedGenre = "MMORPG"
        vm.searchText = "Daunt"
        #expect(vm.filteredGames.count == 1)
    }

    @Test func genresListIncludesTodos() throws {
        let vm = try makeViewModel()
        #expect(vm.genres.first == GenreConstants.allGenresLabel)
        #expect(vm.genres.count == 4) // Todos + MMORPG + RPG + Shooter
    }

    @Test func allGenresShowsAllGames() throws {
        let vm = try makeViewModel()
        vm.selectedGenre = GenreConstants.allGenresLabel
        #expect(vm.filteredGames.count == 3)
    }

    @Test func suggestionsReturnMatchingTitles() throws {
        let vm = try makeViewModel()
        vm.searchText = "World"
        #expect(vm.suggestions.contains("World of Tanks"))
    }

    @Test func suggestionsEmptyWhenNoSearch() throws {
        let vm = try makeViewModel()
        vm.searchText = ""
        #expect(vm.suggestions.isEmpty)
    }

    @Test func searchByGenreName() throws {
        let vm = try makeViewModel()
        vm.searchText = "Shooter"
        #expect(vm.filteredGames.count == 1)
        #expect(vm.filteredGames[0].title == "World of Tanks")
    }
}
