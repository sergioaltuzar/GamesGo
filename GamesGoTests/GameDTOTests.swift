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
        #expect(game.isDeleted == false)
    }

    @Test func decodesEmptyArray() throws {
        let data = "[]".data(using: .utf8)!
        let dtos = try JSONDecoder().decode([GameDTO].self, from: data)
        #expect(dtos.isEmpty)
    }
}
