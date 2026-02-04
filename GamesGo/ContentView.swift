//
//  ContentView.swift
//  GamesGo
//
//  Created by Sergio Altuzar on 01/02/26.
//

import SwiftUI

struct ContentView: View {
    @State private var hasLoaded = false
    @State private var forceReload = false

    var body: some View {
        Group {
            if hasLoaded {
                GameCatalogView(hasLoaded: $hasLoaded, forceReload: $forceReload)
            } else {
                LoadingView(hasLoaded: $hasLoaded, forceReload: $forceReload)
            }
        }
        .preferredColorScheme(.dark)
    }
}
