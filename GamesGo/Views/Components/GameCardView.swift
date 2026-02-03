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
