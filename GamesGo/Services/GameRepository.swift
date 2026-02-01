//
//  GameRepository.swift
//  GamesGo
//
//  Created by Sergio Altuzar on 31/01/26.
//

import Foundation
import SwiftData

@MainActor
final class GameRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func hasGames() -> Bool {
        let descriptor = FetchDescriptor<Game>()
        let count = (try? modelContext.fetchCount(descriptor)) ?? 0
        return count > 0
    }

    func insertGames(_ dtos: [GameDTO]) throws {
        for dto in dtos {
            let game = dto.toGame()
            modelContext.insert(game)
        }
        try modelContext.save()
    }

    func allActiveGames() throws -> [Game] {
        let descriptor = FetchDescriptor<Game>(
            predicate: #Predicate<Game> { $0.isDeleted == false },
            sortBy: [SortDescriptor(\.title)]
        )
        return try modelContext.fetch(descriptor)
    }

    func softDelete(_ game: Game) throws {
        game.isDeleted = true
        try modelContext.save()
    }

    func saveChanges() throws {
        try modelContext.save()
    }
}
