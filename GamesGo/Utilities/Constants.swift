//
//  Constants.swift
//  GamesGo
//
//  Created by Sergio Altuzar on 03/02/26.
//

import SwiftUI

enum Constants {
    static let apiURL = "https://www.freetogame.com/api/games"
}

enum AppColors {
    static let gradientStart = Color(red: 0.05, green: 0.05, blue: 0.2)
    static let gradientEnd = Color(red: 0.25, green: 0.05, blue: 0.4)
    static let accentNeon = Color(red: 0.2, green: 0.6, blue: 1.0)
    static let accentPurple = Color(red: 0.6, green: 0.2, blue: 0.9)
}

enum AppGradients {
    static let background = LinearGradient(
        colors: [AppColors.gradientStart, AppColors.gradientEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
