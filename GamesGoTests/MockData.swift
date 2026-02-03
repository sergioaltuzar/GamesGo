import Foundation
@testable import GamesGo

enum MockData {
    static let sampleJSON = """
    [
        {
            "id": 1,
            "title": "Dauntless",
            "thumbnail": "https://www.freetogame.com/g/1/thumbnail.jpg",
            "short_description": "A free-to-play co-op action RPG.",
            "game_url": "https://www.freetogame.com/open/dauntless",
            "genre": "MMORPG",
            "platform": "PC (Windows)",
            "publisher": "Phoenix Labs",
            "developer": "Phoenix Labs",
            "release_date": "2019-05-21",
            "freetogame_profile_url": "https://www.freetogame.com/dauntless"
        },
        {
            "id": 2,
            "title": "World of Tanks",
            "thumbnail": "https://www.freetogame.com/g/2/thumbnail.jpg",
            "short_description": "A team-based MMO action game.",
            "game_url": "https://www.freetogame.com/open/world-of-tanks",
            "genre": "Shooter",
            "platform": "PC (Windows)",
            "publisher": "Wargaming",
            "developer": "Wargaming",
            "release_date": "2011-04-12",
            "freetogame_profile_url": "https://www.freetogame.com/world-of-tanks"
        },
        {
            "id": 3,
            "title": "Genshin Impact",
            "thumbnail": "https://www.freetogame.com/g/3/thumbnail.jpg",
            "short_description": "An open-world action RPG.",
            "game_url": "https://www.freetogame.com/open/genshin-impact",
            "genre": "RPG",
            "platform": "PC (Windows)",
            "publisher": "miHoYo",
            "developer": "miHoYo",
            "release_date": "2020-09-28",
            "freetogame_profile_url": "https://www.freetogame.com/genshin-impact"
        }
    ]
    """.data(using: .utf8)!

    static func makeSampleDTO() -> GameDTO {
        GameDTO(
            id: 1,
            title: "Dauntless",
            thumbnail: "https://www.freetogame.com/g/1/thumbnail.jpg",
            shortDescription: "A free-to-play co-op action RPG.",
            gameUrl: "https://www.freetogame.com/open/dauntless",
            genre: "MMORPG",
            platform: "PC (Windows)",
            publisher: "Phoenix Labs",
            developer: "Phoenix Labs",
            releaseDate: "2019-05-21",
            freetogameProfileUrl: "https://www.freetogame.com/dauntless"
        )
    }

    static func makeSampleGame() -> Game {
        Game(
            apiId: 1,
            title: "Dauntless",
            thumbnailURL: "https://www.freetogame.com/g/1/thumbnail.jpg",
            shortDescription: "A free-to-play co-op action RPG.",
            gameURL: "https://www.freetogame.com/open/dauntless",
            genre: "MMORPG",
            platform: "PC (Windows)",
            publisher: "Phoenix Labs",
            developer: "Phoenix Labs",
            releaseDate: "2019-05-21",
            freetogameProfileURL: "https://www.freetogame.com/dauntless"
        )
    }
}

final class MockNetworkService: NetworkServiceProtocol {
    var result: Result<[GameDTO], Error> = .success([])

    func fetchGames() async throws -> [GameDTO] {
        try result.get()
    }
}
