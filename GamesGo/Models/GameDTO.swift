//
//  GamesDTO.swift
//  GamesGo
//
//  Created by Sergio Altuzar on 31/01/26.
//

import Foundation

struct GameDTO: Codable, Sendable {
    let id: Int
    let title: String
    let thumbnail: String
    let shortDescription: String
    let gameUrl: String
    let genre: String
    let platform: String
    let publisher: String
    let developer: String
    let releaseDate: String
    let freetogameProfileUrl: String

    enum CodingKeys: String, CodingKey {
        case id, title, thumbnail, genre, platform, publisher, developer
        case shortDescription = "short_description"
        case gameUrl = "game_url"
        case releaseDate = "release_date"
        case freetogameProfileUrl = "freetogame_profile_url"
    }

    func toGame() -> Game {
        Game(
            apiId: id,
            title: title,
            thumbnailURL: thumbnail,
            shortDescription: shortDescription,
            gameURL: gameUrl,
            genre: genre,
            platform: platform,
            publisher: publisher,
            developer: developer,
            releaseDate: releaseDate,
            freetogameProfileURL: freetogameProfileUrl
        )
    }
}
