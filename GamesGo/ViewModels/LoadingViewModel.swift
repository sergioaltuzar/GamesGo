//
//  LoadingViewModel.swift
//  GamesGo
//
//  Created by Sergio Altuzar on 01/02/26.
//

import Foundation
import SwiftData

@Observable
final class LoadingViewModel {
    var isLoading = true
    var errorMessage: String?

    private let networkService: NetworkServiceProtocol
    private let repository: GameRepository

    init(networkService: NetworkServiceProtocol = NetworkService(),
         repository: GameRepository) {
        self.networkService = networkService
        self.repository = repository
    }

    var needsDownload: Bool {
        !repository.hasGames()
    }

    func downloadCatalog() async {
        isLoading = true
        errorMessage = nil
        do {
            let dtos = try await networkService.fetchGames()
            try repository.insertGames(dtos)
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}
