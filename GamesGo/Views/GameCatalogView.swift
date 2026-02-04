//
//  GameCatalogView.swift
//  GamesGo
//
//  Created by Sergio Altuzar on 02/02/26.
//

import SwiftUI
import SwiftData

struct GameCatalogView: View {
    @Binding var hasLoaded: Bool
    @Binding var forceReload: Bool
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: GameCatalogViewModel?
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                AppGradients.background
                    .ignoresSafeArea()

                if let viewModel {
                    catalogContent(viewModel: viewModel)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
        .onAppear {
            if viewModel == nil {
                let repository = GameRepository(modelContext: modelContext)
                viewModel = GameCatalogViewModel(repository: repository)
            }
            viewModel?.loadGames()
        }
        .onChange(of: navigationPath.count) { oldCount, newCount in
            if newCount < oldCount {
                viewModel?.loadGames()
            }
        }
    }

    @ViewBuilder
    private func catalogContent(viewModel: GameCatalogViewModel) -> some View {
        VStack(spacing: 0) {
            SearchBarView(text: Bindable(viewModel).searchText)
                .padding(.horizontal)
                .padding(.top, 8)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.genres, id: \.self) { genre in
                        GenreChipView(
                            title: genre,
                            isSelected: viewModel.selectedGenre == genre
                        ) {
                            viewModel.selectedGenre = genre
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 12)

            if !viewModel.searchText.isEmpty && !viewModel.suggestions.isEmpty {
                suggestionsOverlay(viewModel: viewModel)
            }

            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(viewModel.filteredGames, id: \.apiId) { game in
                        NavigationLink(value: game.persistentModelID) {
                            GameCardView(game: game)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .scrollDismissesKeyboard(.immediately)
        }
        .navigationTitle("Game Library")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    forceReload = true
                    hasLoaded = false
                } label: {
                    Image(systemName: "arrow.trianglehead.2.clockwise")
                        .foregroundStyle(AppColors.accentNeon)
                }
            }
        }
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationDestination(for: PersistentIdentifier.self) { id in
            GameDetailDestination(gameID: id)
        }
    }

    @ViewBuilder
    private func suggestionsOverlay(viewModel: GameCatalogViewModel) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(viewModel.suggestions, id: \.self) { suggestion in
                Button {
                    viewModel.searchText = suggestion
                } label: {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.4))
                        Text(suggestion)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.8))
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.plain)

                if suggestion != viewModel.suggestions.last {
                    Divider()
                        .background(Color.white.opacity(0.1))
                }
            }
        }
        .glassBackground(cornerRadius: 12)
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}

private struct GameDetailDestination: View {
    let gameID: PersistentIdentifier
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        if let game = modelContext.model(for: gameID) as? Game {
            GameDetailView(
                game: game,
                repository: GameRepository(modelContext: modelContext)
            )
        } else {
            ContentUnavailableView("Game not found", systemImage: "exclamationmark.triangle")
        }
    }
}

#Preview {
    GameCatalogView(hasLoaded: .constant(true), forceReload: .constant(false))
        .modelContainer(for: Game.self, inMemory: true)
}
