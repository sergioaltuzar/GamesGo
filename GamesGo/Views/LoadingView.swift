//
//  LoadingView.swift
//  GamesGo
//
//  Created by Sergio Altuzar on 02/02/26.
//

import SwiftUI
import SwiftData
import Combine

struct LoadingView: View {
    @Binding var hasLoaded: Bool
    @Binding var forceReload: Bool
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: LoadingViewModel?
    @State private var animateGradient = false
    @State private var ringRotation: Double = 0
    @State private var ringScale: CGFloat = 0.8
    @State private var pulseOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var dotCount = 0

    private let timer = Timer.publish(every: 0.4, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                colors: [
                    AppColors.gradientStart,
                    AppColors.gradientEnd,
                    AppColors.accentPurple.opacity(0.4),
                    AppColors.gradientStart
                ],
                startPoint: animateGradient ? .topLeading : .bottomTrailing,
                endPoint: animateGradient ? .bottomTrailing : .topLeading
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                    animateGradient = true
                }
            }

            // Pulsing glow behind the ring
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            AppColors.accentNeon.opacity(0.3),
                            AppColors.accentPurple.opacity(0.1),
                            .clear
                        ],
                        center: .center,
                        startRadius: 30,
                        endRadius: 140
                    )
                )
                .frame(width: 280, height: 280)
                .opacity(pulseOpacity)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                        pulseOpacity = 1
                    }
                }

            VStack(spacing: 36) {
                // Custom spinning ring
                ZStack {
                    // Outer ring track
                    Circle()
                        .stroke(Color.white.opacity(0.08), lineWidth: 4)
                        .frame(width: 80, height: 80)

                    // Spinning arc
                    Circle()
                        .trim(from: 0, to: 0.65)
                        .stroke(
                            AngularGradient(
                                colors: [
                                    AppColors.accentNeon.opacity(0),
                                    AppColors.accentNeon,
                                    AppColors.accentPurple
                                ],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(ringRotation))

                    // Inner ring
                    Circle()
                        .trim(from: 0, to: 0.4)
                        .stroke(
                            AppColors.accentPurple.opacity(0.6),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .frame(width: 54, height: 54)
                        .rotationEffect(.degrees(-ringRotation * 0.7))

                    // Center icon
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppColors.accentNeon, AppColors.accentPurple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(ringScale)
                }
                .onAppear {
                    withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                        ringRotation = 360
                    }
                    withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                        ringScale = 1.1
                    }
                }

                // Text
                VStack(spacing: 10) {
                    Text("Loading your games" + String(repeating: ".", count: dotCount))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())

                    Text("Syncing catalog")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.5))
                }
                .opacity(textOpacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 0.6)) {
                        textOpacity = 1
                    }
                }
                .onReceive(timer) { _ in
                    withAnimation {
                        dotCount = (dotCount % 3) + 1
                    }
                }

                // Error state
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
                                    try? await Task.sleep(for: .seconds(3))
                                    hasLoaded = true
                                }
                            }
                        }
                        .buttonStyle(.bordered)
                        .tint(AppColors.accentNeon)
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding()
        }
        .task {
            let repository = GameRepository(modelContext: modelContext)
            let vm = LoadingViewModel(repository: repository)
            viewModel = vm

            let minDisplay = Task {
                try? await Task.sleep(for: .seconds(3))
            }

            if forceReload || vm.needsDownload {
                await vm.downloadCatalog()
                forceReload = false
            }

            await minDisplay.value

            if vm.errorMessage == nil {
                hasLoaded = true
            }
        }
    }
}

#Preview {
    LoadingView(hasLoaded: .constant(false), forceReload: .constant(false))
        .modelContainer(for: Game.self, inMemory: true)
}
