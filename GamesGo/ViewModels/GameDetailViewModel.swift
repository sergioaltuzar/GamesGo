//
//  GameDetailViewModel.swift
//  GamesGo
//
//  Created by Sergio Altuzar on 01/02/26.
//

import Foundation
import SwiftData

@Observable
final class GameDetailViewModel {
    var game: Game
    var userNotes: String
    var showDeleteConfirmation: Bool = false
    var didDelete: Bool = false

    private let repository: GameRepository

    init(game: Game, repository: GameRepository) {
        self.game = game
        self.userNotes = game.userNotes
        self.repository = repository
    }

    func saveNotes() {
        game.userNotes = userNotes
        try? repository.saveChanges()
    }

    func deleteGame() {
        try? repository.softDelete(game)
        didDelete = true
    }
}
