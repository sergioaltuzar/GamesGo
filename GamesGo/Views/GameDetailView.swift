//
//  GameDetailView.swift
//  GamesGo
//
//  Created by Sergio Altuzar on 02/02/26.
//

import SwiftUI
import SwiftData

struct GameDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: GameDetailViewModel

    init(game: Game, repository: GameRepository) {
        _viewModel = State(initialValue: GameDetailViewModel(game: game, repository: repository))
    }

    var body: some View {
        ZStack {
            AppGradients.background
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ZStack(alignment: .bottom) {
                        GeometryReader { geo in
                            AsyncGameImage(url: viewModel.game.thumbnailURL, contentMode: .fill)
                                .frame(width: geo.size.width, height: 260)
                                .clipped()
                        }
                        .frame(height: 260)

                        LinearGradient(
                            colors: [.clear, AppColors.gradientStart],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 120)
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        Text(viewModel.game.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .fixedSize(horizontal: false, vertical: true)

                        FlowLayout(spacing: 8) {
                            TagView(text: viewModel.game.genre, color: AppColors.accentNeon)
                            TagView(text: viewModel.game.platform, color: AppColors.accentPurple)
                        }

                        Text(viewModel.game.shortDescription)
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.8))
                            .fixedSize(horizontal: false, vertical: true)

                        VStack(alignment: .leading, spacing: 8) {
                            InfoRow(label: "Developer", value: viewModel.game.developer)
                            InfoRow(label: "Publisher", value: viewModel.game.publisher)
                            InfoRow(label: "Release Date", value: viewModel.game.releaseDate)
                        }
                        .padding(.vertical, 8)

                        Divider()
                            .background(Color.white.opacity(0.2))

                        VStack(alignment: .leading, spacing: 10) {
                            Text("User Notes")
                                .font(.headline)
                                .foregroundStyle(.white)

                            TextEditor(text: $viewModel.userNotes)
                                .scrollContentBackground(.hidden)
                                .foregroundStyle(.white)
                                .frame(minHeight: 100)
                                .padding(10)
                                .glassBackground(cornerRadius: 10)
                        }

                        Divider()
                            .background(Color.white.opacity(0.2))

                        Button {
                            viewModel.showDeleteConfirmation = true
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                Text("Remove from Library")
                            }
                            .font(.headline)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.red.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(.red.opacity(0.4), lineWidth: 1)
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(20)
                    .glassBackground(cornerRadius: 20)
                    .padding(.top, -30)
                }
                .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.immediately)
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .confirmationDialog(
            "Delete Game",
            isPresented: $viewModel.showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                viewModel.deleteGame()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This game will be removed from your library. Tap reload to show it again.")
        }
        .onDisappear {
            if !viewModel.didDelete {
                viewModel.saveNotes()
            }
        }
    }

}


private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        var totalWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            totalWidth = max(totalWidth, x - spacing)
            totalHeight = y + rowHeight
        }

        return (positions, CGSize(width: totalWidth, height: totalHeight))
    }
}

private struct TagView: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(color.opacity(0.3))
                    .overlay(
                        Capsule()
                            .stroke(color.opacity(0.6), lineWidth: 1)
                    )
            )
    }
}

private struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.5))
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
        }
    }
}

#Preview {
    NavigationStack {
        GameDetailView(
            game: Game(
                apiId: 1,
                title: "Dauntless",
                thumbnailURL: "https://www.freetogame.com/g/540/thumbnail.jpg",
                shortDescription: "A free-to-play co-op action RPG with gameplay similar to Monster Hunter.",
                gameURL: "https://www.freetogame.com/open/dauntless",
                genre: "MMORPG",
                platform: "PC (Windows)",
                publisher: "Phoenix Labs",
                developer: "Phoenix Labs",
                releaseDate: "2019-05-21",
                freetogameProfileURL: "https://www.freetogame.com/dauntless"
            ),
            repository: GameRepository(
                modelContext: try! ModelContainer(
                    for: Game.self,
                    configurations: ModelConfiguration(isStoredInMemoryOnly: true)
                ).mainContext
            )
        )
    }
}
