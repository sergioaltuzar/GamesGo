//
//  SearchBarView.swift
//  GamesGo
//
//  Created by Sergio Altuzar on 02/02/26.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.white.opacity(0.6))

            TextField("Search games...", text: $text)
                .foregroundStyle(.white)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .glassBackground(cornerRadius: 12)
    }
}

#Preview {
    ZStack {
        AppGradients.background
            .ignoresSafeArea()
        SearchBarView(text: .constant("Dauntless"))
            .padding()
    }
    .preferredColorScheme(.dark)
}
