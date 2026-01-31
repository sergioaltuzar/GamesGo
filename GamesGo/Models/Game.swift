//
//  GamesGoApp.swift
//  GamesGo
//
//  Created by Sergio Altuzar on 31/01/26.
//

import Foundation
import SwiftData

@Model
final class Game {
    #Unique<Game>([\.apiId])

    var apiId: Int
    var title: String
    var thumbnailURL: String
    var shortDescription: String
    var gameURL: String
    var genre: String
    var platform: String
    var publisher: String
    var developer: String
    var releaseDate: String
    var freetogameProfileURL: String
    var userNotes: String
    var isDeleted: Bool

    init(
        apiId: Int,
        title: String,
        thumbnailURL: String,
        shortDescription: String,
        gameURL: String,
        genre: String,
        platform: String,
        publisher: String,
        developer: String,
        releaseDate: String,
        freetogameProfileURL: String,
        userNotes: String = "",
        isDeleted: Bool = false
    ) {
        self.apiId = apiId
        self.title = title
        self.thumbnailURL = thumbnailURL
        self.shortDescription = shortDescription
        self.gameURL = gameURL
        self.genre = genre
        self.platform = platform
        self.publisher = publisher
        self.developer = developer
        self.releaseDate = releaseDate
        self.freetogameProfileURL = freetogameProfileURL
        self.userNotes = userNotes
        self.isDeleted = isDeleted
    }
}
