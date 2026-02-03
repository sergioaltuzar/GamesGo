import Testing
import Foundation
@testable import GamesGo

struct GameDTOTests {
    @Test func decodesValidJSON() throws {
        let dtos = try JSONDecoder().decode([GameDTO].self, from: MockData.sampleJSON)
        #expect(dtos.count == 3)
        #expect(dtos[0].id == 1)
        #expect(dtos[0].title == "Dauntless")
        #expect(dtos[0].shortDescription == "A free-to-play co-op action RPG.")
        #expect(dtos[0].genre == "MMORPG")
        #expect(dtos[0].releaseDate == "2019-05-21")
    }

    @Test func decodesAllFieldsOfSecondItem() throws {
        let dtos = try JSONDecoder().decode([GameDTO].self, from: MockData.sampleJSON)
        let dto = dtos[1]
        #expect(dto.id == 2)
        #expect(dto.title == "World of Tanks")
        #expect(dto.thumbnail == "https://www.freetogame.com/g/2/thumbnail.jpg")
        #expect(dto.shortDescription == "A team-based MMO action game.")
        #expect(dto.gameUrl == "https://www.freetogame.com/open/world-of-tanks")
        #expect(dto.genre == "Shooter")
        #expect(dto.platform == "PC (Windows)")
        #expect(dto.publisher == "Wargaming")
        #expect(dto.developer == "Wargaming")
        #expect(dto.releaseDate == "2011-04-12")
        #expect(dto.freetogameProfileUrl == "https://www.freetogame.com/world-of-tanks")
    }

    @Test func toGameMapsAllFields() {
        let dto = MockData.makeSampleDTO()
        let game = dto.toGame()
        #expect(game.apiId == dto.id)
        #expect(game.title == dto.title)
        #expect(game.thumbnailURL == dto.thumbnail)
        #expect(game.shortDescription == dto.shortDescription)
        #expect(game.gameURL == dto.gameUrl)
        #expect(game.genre == dto.genre)
        #expect(game.platform == dto.platform)
        #expect(game.publisher == dto.publisher)
        #expect(game.developer == dto.developer)
        #expect(game.releaseDate == dto.releaseDate)
        #expect(game.freetogameProfileURL == dto.freetogameProfileUrl)
        #expect(game.userNotes == "")
        #expect(game.isRemoved == false)
    }

    @Test func decodesEmptyArray() throws {
        let data = "[]".data(using: .utf8)!
        let dtos = try JSONDecoder().decode([GameDTO].self, from: data)
        #expect(dtos.isEmpty)
    }

    @Test func failsToDecodeInvalidJSON() {
        let data = "not json".data(using: .utf8)!
        #expect(throws: (any Error).self) {
            try JSONDecoder().decode([GameDTO].self, from: data)
        }
    }

    @Test func failsToDecodeMissingRequiredField() {
        let json = """
        [{"id": 1, "title": "Test"}]
        """.data(using: .utf8)!
        #expect(throws: (any Error).self) {
            try JSONDecoder().decode([GameDTO].self, from: json)
        }
    }

    @Test func decodesSnakeCaseKeys() throws {
        let json = """
        [{
            "id": 99,
            "title": "Test",
            "thumbnail": "url",
            "short_description": "desc",
            "game_url": "gurl",
            "genre": "RPG",
            "platform": "PC",
            "publisher": "Pub",
            "developer": "Dev",
            "release_date": "2024-01-01",
            "freetogame_profile_url": "profile"
        }]
        """.data(using: .utf8)!
        let dtos = try JSONDecoder().decode([GameDTO].self, from: json)
        #expect(dtos[0].shortDescription == "desc")
        #expect(dtos[0].gameUrl == "gurl")
        #expect(dtos[0].releaseDate == "2024-01-01")
        #expect(dtos[0].freetogameProfileUrl == "profile")
    }

    @Test func toGameSetsDefaultValues() {
        let dto = MockData.makeSampleDTO()
        let game = dto.toGame()
        #expect(game.userNotes.isEmpty)
        #expect(game.isRemoved == false)
    }
}
