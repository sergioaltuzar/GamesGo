//
//  GamesGoApp.swift
//  GamesGo
//
//  Created by Sergio Altuzar on 31/01/26.
//

import SwiftUI
import SwiftData

@main
struct GamesGoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Game.self)
    }
}
