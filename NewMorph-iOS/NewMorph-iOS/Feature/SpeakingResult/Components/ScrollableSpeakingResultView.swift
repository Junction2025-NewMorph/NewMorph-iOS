//
//  ScrollableSpeakingResultView.swift
//  NewMorph-iOS
//
//  Created by OneThing on 8/23/25.
//

import SwiftUI

struct ScrollableSpeakingResultView: View {
    @StateObject private var speakingResultViewModel: SpeakingResultViewModel
    @StateObject private var expressionViewModel: ExpressionViewModel
    @State private var scrollOffset: CGFloat = 0
    @State private var showExpression = false

    init(
        speakingResultViewModel: SpeakingResultViewModel,
        expressionViewModel: ExpressionViewModel
    ) {
        self._speakingResultViewModel = StateObject(
            wrappedValue: speakingResultViewModel
        )
        self._expressionViewModel = StateObject(
            wrappedValue: expressionViewModel
        )
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        // SpeakingResult section
                        speakingResultSection
                            .frame(height: geometry.size.height)
                            .id("speakingResult")

                        // Expression section
                        expressionSection
                            .frame(minHeight: geometry.size.height)
                            .id("expression")
                    }
                }
                .background(Color(.nmBackgroundResult))
                .scrollIndicators(.hidden)
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .preference(
                                key: ScrollOffsetPreferenceKey.self,
                                value: geo.frame(in: .named("scroll")).minY
                            )
                    }
                )
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    scrollOffset = value
                    updateExpressionVisibility(geometry: geometry)
                }
                .onChange(of: showExpression) { _, newValue in
                    if !newValue {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            proxy.scrollTo("speakingResult", anchor: .top)
                        }
                    }
                }
            }
        }
        .background(Color(.nmBackgroundResult))
//        .ignoresSafeArea()
        .task {
            await expressionViewModel.generateExpressions()
        }
    }

    private var speakingResultSection: some View {
        VStack(spacing: 0) {
            // Top section with status bar style
            topSection

            // Main speaking result content
            VStack(spacing: 32) {
                // Rising score notification
                if speakingResultViewModel.state.isFillingScoreRising {
                    risingScoreNotification
                }

                // Score cards
                scoreCardsSection

                // Scroll hint
                scrollHint

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .background(Color.clear)
    }

    private var expressionSection: some View {
        VStack(spacing: 0) {
            // Top navigation area with scroll back button
            HStack {
                Spacer()
                Button(action: {
                    showExpression = false
                }) {
                    Image(systemName: "chevron.up")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
                Spacer()
            }
            .padding(.top, 10)
            .padding(.horizontal, 20)

            // Expression content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(expressionViewModel.state.originalText)
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 20)

                        VStack(alignment: .leading, spacing: 8) {
                            Rectangle()
                                .fill(Color(.systemGray6))
                                .frame(height: 4)
                                .padding(.leading, 20)

                            Text(expressionViewModel.state.translatedText)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemGray6))
                                )
                                .padding(.horizontal, 20)
                        }
                    }
                    .padding(.top, 30)

                    VStack(alignment: .leading, spacing: 16) {
                        Text("In other cases")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 20)

                        ExpressionCardsScrollView(
                            viewModel: expressionViewModel
                        )
                    }
                    .padding(.top, 40)

                    Spacer(minLength: 100)
                }
            }
            .scrollDisabled(true)  // Disable inner scrolling

            // Bottom Save button
            VStack(spacing: 0) {
                Divider()

                Button(action: {
                    Task {
                        await expressionViewModel.saveExpression()
                    }
                }) {
                    Text("Save")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.black)
                        .cornerRadius(0)
                }
            }
        }
        .background(Color(.nmBackgroundResult))
    }

    // MARK: - SpeakingResult Components

    private var topSection: some View {
        VStack(spacing: 16) {

            // Date and home icon
            HStack {
                Text(speakingResultViewModel.state.currentDate)
                    .font(.title3)
                    .fontWeight(.medium)

                Spacer()

                Button(action: {}) {
                    Image(systemName: "house.fill")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private var risingScoreNotification: some View {
        HStack {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.title3)
                .foregroundColor(.green)

            Text("Filling Score is on the rise!")
                .font(.body)
                .fontWeight(.medium)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.green.opacity(0.1))
        )
    }

    private var scoreCardsSection: some View {
        VStack(spacing: 24) {
            ScoreCard(scoreData: speakingResultViewModel.state.feelingScore)
            ScoreCard(scoreData: speakingResultViewModel.state.fillingScore)
        }
    }

    private var scrollHint: some View {
        VStack(spacing: 12) {
            Text("Scroll to see feedback")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Image(systemName: "chevron.down")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.top, 40)
    }

    // MARK: - Helper Methods

    private func updateExpressionVisibility(geometry: GeometryProxy) {
        let threshold = geometry.size.height * 0.5
        showExpression = scrollOffset < -threshold
    }
}

// Preference key for tracking scroll offset
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    let speakingResultVM = SpeakingResultViewModel()
    let container = AppContainer.mock()
    let expressionVM = ExpressionViewModel(
        useCase: container.normalizeEnglishUseCase,
        targetDate: Date()
    )

    ScrollableSpeakingResultView(
        speakingResultViewModel: speakingResultVM,
        expressionViewModel: expressionVM
    )
}
