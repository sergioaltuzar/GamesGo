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
        let existingGames = try modelContext.fetch(FetchDescriptor<Game>())
        let existingByApiId = Dictionary(uniqueKeysWithValues: existingGames.map { ($0.apiId, $0) })

        for dto in dtos {
            if let existing = existingByApiId[dto.id] {
                existing.title = dto.title
                existing.thumbnailURL = dto.thumbnail
                existing.shortDescription = dto.shortDescription
                existing.gameURL = dto.gameUrl
                existing.genre = dto.genre
                existing.platform = dto.platform
                existing.publisher = dto.publisher
                existing.developer = dto.developer
                existing.releaseDate = dto.releaseDate
                existing.freetogameProfileURL = dto.freetogameProfileUrl
                existing.isRemoved = false
            } else {
                let game = dto.toGame()
                modelContext.insert(game)
            }
        }
        try modelContext.save()
    }

    func allActiveGames() throws -> [Game] {
        let descriptor = FetchDescriptor<Game>(
            predicate: #Predicate<Game> { $0.isRemoved == false },
            sortBy: [SortDescriptor(\.title)]
        )
        return try modelContext.fetch(descriptor)
    }

    func softDelete(_ game: Game) throws {
        game.isRemoved = true
        try modelContext.save()
    }

    func saveChanges() throws {
        try modelContext.save()
    }
}
