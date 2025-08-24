//
//  SpeakingResultView.swift
//  NewMorph-iOS
//
//  Created by OneThing on 8/23/25.
//

import SwiftUI

struct SpeakingResultView: View {
    @StateObject private var viewModel: SpeakingResultViewModel
    @StateObject private var expressionViewModel: ExpressionViewModel
    @State private var showExpression = false
    
    init(viewModel: SpeakingResultViewModel, expressionViewModel: ExpressionViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._expressionViewModel = StateObject(wrappedValue: expressionViewModel)
    }
    
    var body: some View {
        ZStack {
            if showExpression {
                ExpressionView(viewModel: expressionViewModel)
                    .transition(.move(edge: .bottom))
            } else {
                mainSpeakingResultView
                    .transition(.move(edge: .top))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showExpression)
    }
    
    private var mainSpeakingResultView: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        // Dashboard content
                        speakingResultContent
                            .frame(minHeight: geometry.size.height)
                        
                        // Invisible trigger area for ExpressionView
                        Color.clear
                            .frame(height: 100)
                            .onAppear {
                                showExpression = true
                            }
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
    }
    
    private var speakingResultContent: some View {
        VStack(spacing: 0) {
            // Top section with status bar style
            topSection
            
            // Main content
            VStack(spacing: 24) {
                // Rising score notification
                if viewModel.state.isFillingScoreRising {
                    risingScoreNotification
                }
                
                // Score cards
                scoreCardsSection
                
                // Scroll hint
                scrollHint
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
        }
        .background(Color(.nmBackgroundResult))
    }
    
    private var topSection: some View {
        VStack(spacing: 16) {
            // Centered title with home icon
            HStack {
                Button(action: {}) {
                    Image("icn_home")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text("결과 보기")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                // Invisible spacer to balance the home icon
                Image("icn_home")
                    .font(.title2)
                    .foregroundColor(.clear)
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var risingScoreNotification: some View {
        HStack {
            Image("icn_trending_up")
                .font(.title3)
                .foregroundColor(Color("nmPointGreen1"))
            
            Text("Filling Score is on the rise!")
                .font(.body)
                .fontWeight(.medium)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("nmPointGreen1").opacity(0.1))
        )
    }
    
    private var scoreCardsSection: some View {
        VStack(spacing: 20) {
            ScoreCard(scoreData: viewModel.state.feelingScore)
            ScoreCard(scoreData: viewModel.state.fillingScore)
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
}

// Connected ExpressionView that can scroll back to SpeakingResult
struct ConnectedExpressionView: View {
    @StateObject private var expressionViewModel: ExpressionViewModel
    @Binding var showSpeakingResult: Bool
    
    init(expressionViewModel: ExpressionViewModel, showSpeakingResult: Binding<Bool>) {
        self._expressionViewModel = StateObject(wrappedValue: expressionViewModel)
        self._showSpeakingResult = showSpeakingResult
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    // Invisible trigger area for SpeakingResult
                    Color.clear
                        .frame(height: 100)
                        .onAppear {
                            // Trigger when scrolled to top
                        }
                    
                    // Expression content
                    expressionContent
                        .frame(minHeight: geometry.size.height)
                }
            }
            .scrollIndicators(.hidden)
        }
    }
    
    private var expressionContent: some View {
        VStack(spacing: 0) {
            // Top navigation area
            HStack {
                Spacer()
                Button(action: {
                    showSpeakingResult = true
                }) {
                    Image(systemName: "chevron.up")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
                Spacer()
            }
            .padding(.top, 10)
            .padding(.horizontal, 20)
            
            // Expression content (reusing from ExpressionView)
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
                    
                    ExpressionCardsScrollView(viewModel: expressionViewModel)
                }
                .padding(.top, 40)
                
                Spacer(minLength: 100)
            }
            
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
}

#Preview {
    let speakingResultVM = SpeakingResultViewModel()
    let container = AppContainer.mock()
    let expressionVM = ExpressionViewModel(useCase: container.normalizeEnglishUseCase, targetDate: Date())
    
    SpeakingResultView(viewModel: speakingResultVM, expressionViewModel: expressionVM)
}
