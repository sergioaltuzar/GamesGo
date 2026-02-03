//
//  GenreChipView.swift
//  GamesGo
//
//  Created by Sergio Altuzar on 02/02/26.
//

import SwiftUI

struct GenreChipView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(isSelected ? .white : .white.opacity(0.7))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background {
                    if isSelected {
                        Capsule()
                            .fill(AppColors.accentNeon.opacity(0.4))
                            .overlay(
                                Capsule()
                                    .stroke(AppColors.accentNeon, lineWidth: 1)
                            )
                    } else {
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        AppGradients.background
            .ignoresSafeArea()
        HStack {
            GenreChipView(title: "All", isSelected: true) {}
            GenreChipView(title: "RPG", isSelected: false) {}
            GenreChipView(title: "Shooter", isSelected: false) {}
        }
        .padding()
    }
    .preferredColorScheme(.dark)
}
