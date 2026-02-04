//
//  AsyncGameImage.swift
//  GamesGo
//
//  Created by Sergio Altuzar on 02/02/26.
//

import SwiftUI

struct AsyncGameImage: View {
    let url: String
    var contentMode: ContentMode = .fill

    @State private var image: UIImage?
    @State private var isLoading = true

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else if isLoading {
                Rectangle()
                    .fill(Color.white.opacity(0.05))
                    .overlay {
                        ProgressView()
                            .tint(AppColors.accentNeon)
                    }
            } else {
                Rectangle()
                    .fill(Color.white.opacity(0.05))
                    .overlay {
                        Image(systemName: "gamecontroller")
                            .font(.title2)
                            .foregroundStyle(.white.opacity(0.3))
                    }
            }
        }
        .task(id: url) {
            await loadImage()
        }
    }

    private func loadImage() async {
        if let cached = await ImageCache.shared.image(for: url) {
            image = cached
            isLoading = false
            return
        }
        guard let imageURL = URL(string: url) else {
            isLoading = false
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: imageURL)
            if let downloaded = UIImage(data: data) {
                await ImageCache.shared.store(downloaded, for: url)
                image = downloaded
            }
        } catch {

        }
        isLoading = false
    }
}

#Preview {
    ZStack {
        AppGradients.background
            .ignoresSafeArea()
        AsyncGameImage(url: "https://www.freetogame.com/g/540/thumbnail.jpg")
            .frame(width: 200, height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    .preferredColorScheme(.dark)
}
