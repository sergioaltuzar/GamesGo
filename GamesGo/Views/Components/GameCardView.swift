//
//  GameCardView.swift
//  GamesGo
//
//  Created by Sergio Altuzar on 02/02/26.
//

import SwiftUI
import SwiftData

struct GameCardView: View {
    let game: Game

    private var gameTags: [String] {
        var tags: [String] = []
        let genres = game.genre
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
        tags.append(contentsOf: genres)
        if tags.count < 2 {
            let platforms = game.platform
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
            tags.append(contentsOf: platforms)
        }
        return Array(tags.prefix(2))
    }

    var body: some View {
        HStack(spacing: 14) {
            AsyncGameImage(url: game.thumbnailURL)
                .frame(width: 70, height: 70)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(game.title)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text(game.shortDescription)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
                    .lineLimit(2)

                HStack(spacing: 6) {
                    ForEach(gameTags.prefix(2), id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.white.opacity(0.85))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(AppColors.accentNeon.opacity(0.25))
                                    .overlay(
                                        Capsule()
                                            .stroke(AppColors.accentNeon.opacity(0.5), lineWidth: 0.5)
                                    )
                            )
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.4))
        }
        .padding(12)
        .glassBackground(cornerRadius: 14)
    }
}

#Preview {
    ZStack {
        AppGradients.background
            .ignoresSafeArea()
        GameCardView(
            game: Game(
                apiId: 1,
                title: "Dauntless",
                thumbnailURL: "https://www.freetogame.com/g/540/thumbnail.jpg",
                shortDescription: "A free-to-play co-op action RPG with gameplay similar to Monster Hunter.",
                gameURL: "",
                genre: "MMORPG",
                platform: "PC (Windows)",
                publisher: "Phoenix Labs",
                developer: "Phoenix Labs",
                releaseDate: "2019-05-21",
                freetogameProfileURL: ""
            )
        )
        .padding()
    }
    .modelContainer(for: Game.self, inMemory: true)
    .preferredColorScheme(.dark)
}
