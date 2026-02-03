//
//  GlassBackground.swift
//  GamesGo
//
//  Created by Sergio Altuzar on 02/02/26.
//

import SwiftUI

struct GlassBackground: ViewModifier {
    var cornerRadius: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
    }
}

extension View {
    func glassBackground(cornerRadius: CGFloat = 16) -> some View {
        modifier(GlassBackground(cornerRadius: cornerRadius))
    }
}

#Preview {
    ZStack {
        AppGradients.background
            .ignoresSafeArea()
        Text("Glass Effect")
            .foregroundStyle(.white)
            .padding(30)
            .glassBackground()
    }
    .preferredColorScheme(.dark)
}
