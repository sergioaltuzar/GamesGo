//
//  LoadingView.swift
//  GamesGo
//
//  Created by Sergio Altuzar on 02/02/26.
//

import SwiftUI
import SwiftData

struct LoadingView: View {
    @Binding var hasLoaded: Bool
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: LoadingViewModel?
    @State private var animateGradient = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppColors.gradientStart, AppColors.gradientEnd, AppColors.accentPurple.opacity(0.3)],
                startPoint: animateGradient ? .topLeading : .bottomLeading,
                endPoint: animateGradient ? .bottomTrailing : .topTrailing
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    animateGradient = true
                }
            }

            VStack(spacing: 24) {
                ProgressView()
                    .controlSize(.large)
                    .tint(AppColors.accentNeon)

                VStack(spacing: 8) {
                    Text("Downloading catalog...")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)

                    Text("Syncing database...")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                }

                if let errorMessage = viewModel?.errorMessage {
                    VStack(spacing: 12) {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red.opacity(0.8))
                            .multilineTextAlignment(.center)

                        Button("Retry") {
                            Task {
                                await viewModel?.downloadCatalog()
                                if viewModel?.errorMessage == nil {
                                    hasLoaded = true
                                }
                            }
                        }
                        .buttonStyle(.bordered)
                        .tint(AppColors.accentNeon)
                    }
                }
            }
            .padding()
        }
        .task {
            let repository = GameRepository(modelContext: modelContext)
            let vm = LoadingViewModel(repository: repository)
            viewModel = vm

            if !vm.needsDownload {
                hasLoaded = true
                return
            }

            await vm.downloadCatalog()
            if vm.errorMessage == nil {
                hasLoaded = true
            }
        }
    }
}

#Preview {
    LoadingView(hasLoaded: .constant(false))
        .modelContainer(for: Game.self, inMemory: true)
}
