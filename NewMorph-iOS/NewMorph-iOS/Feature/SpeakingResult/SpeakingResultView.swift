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
                ExpressionView(viewModel: expressionViewModel) {
                    showExpression = false
                }
                .transition(.move(edge: .bottom))
                .onAppear {
                    // 테스트용 데이터 설정 (실제 앱에서는 실제 데이터로 대체)
                    expressionViewModel.updateUserSpeechText("I just finished Crash Landing on You. I liked it lot — some parts were kinda cringy, but overall it was super fun")
                    expressionViewModel.updateCorrectText("I just finished Crash Landing on You. I liked it a lot — some parts were kinda cringy, but overall it was super fun")
                }
            } else {
                mainSpeakingResultView
                    .transition(.move(edge: .top))
            }
        }
        .background(Color(.systemBackground))
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
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
                .background(Color.clear)
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


#Preview {
    let speakingResultVM = SpeakingResultViewModel()
    let container = AppContainer.mock()
    let expressionVM = ExpressionViewModel(useCase: container.normalizeEnglishUseCase, targetDate: Date())
    
    SpeakingResultView(viewModel: speakingResultVM, expressionViewModel: expressionVM)
}
