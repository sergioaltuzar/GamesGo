//
//  NetworkService.swift
//  GamesGo
//
//  Created by Sergio Altuzar on 31/01/26.
//

import Foundation

protocol NetworkServiceProtocol {
    func fetchGames() async throws -> [GameDTO]
}

final class NetworkService: NetworkServiceProtocol {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchGames() async throws -> [GameDTO] {
        guard let url = URL(string: Constants.apiURL) else {
            throw NetworkError.invalidURL
        }
        let (data, response) = try await session.data(from: url)
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
        case .invalidURL: "Invalid URL"
        case .badResponse: "Server response error"
        case .decodingFailed: "Failed to process data"
        }
    }
}
