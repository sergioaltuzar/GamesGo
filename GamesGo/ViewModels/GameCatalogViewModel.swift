//
//  GameCatalogViewModel.swift
//  GamesGo
//
//  Created by Sergio Altuzar on 01/02/26.
//

import Foundation
import SwiftData

@Observable
final class GameCatalogViewModel {
    var searchText: String = ""
    var selectedGenre: String = GenreConstants.allGenresLabel
    var allGames: [Game] = []

    private let repository: GameRepository

    init(repository: GameRepository) {
        self.repository = repository
    }

    var genres: [String] {
        let genreSet = Set(allGames.map(\.genre))
        let sorted = genreSet.sorted()
        return [GenreConstants.allGenresLabel] + sorted
    }

    var filteredGames: [Game] {
        allGames.filter { game in
            let matchesGenre = selectedGenre == GenreConstants.allGenresLabel
                || game.genre == selectedGenre
            let matchesSearch = searchText.isEmpty
                || game.title.localizedCaseInsensitiveContains(searchText)
                || game.genre.localizedCaseInsensitiveContains(searchText)
            return matchesGenre && matchesSearch
        }
    }

    var suggestions: [String] {
        guard !searchText.isEmpty else { return [] }
        let titles = allGames
            .map(\.title)
            .filter { $0.localizedCaseInsensitiveContains(searchText) }
        return Array(titles.prefix(5))
    }

    func loadGames() {
        do {
            allGames = try repository.allActiveGames()
        } catch {
            allGames = []
        }
    }
}
