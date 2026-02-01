import Foundation

protocol NetworkServiceProtocol {
    func fetchGames() async throws -> [GameDTO]
}

final class NetworkService: NetworkServiceProtocol {
    func fetchGames() async throws -> [GameDTO] {
        guard let url = URL(string: Constants.apiURL) else {
            throw NetworkError.invalidURL
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.badResponse
        }
        return try JSONDecoder().decode([GameDTO].self, from: data)
    }
}

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case badResponse
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .invalidURL: "URL invalida"
        case .badResponse: "Error en la respuesta del servidor"
        case .decodingFailed: "Error al procesar los datos"
        }
    }
}
