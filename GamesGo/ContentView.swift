//
//  ContentView.swift
//  GamesGo
//
//  Created by Sergio Altuzar on 01/02/26.
//

import SwiftUI

struct ContentView: View {
    @State private var hasLoaded = false

    var body: some View {
        Group {
            if hasLoaded {
                GameCatalogView()
            } else {
                LoadingView(hasLoaded: $hasLoaded)
            }
        }
        .preferredColorScheme(.dark)
    }
}
