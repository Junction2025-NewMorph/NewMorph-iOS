//
//  SpeakingResultViewModel.swift
//  NewMorph-iOS
//
//  Created by OneThing on 8/23/25.
//

import Combine
import Foundation

@MainActor
final class SpeakingResultViewModel: ObservableObject {
    
    @Published private(set) var state = SpeakingResultViewState()
    
    init() {
        // 목 데이터 설정
        setupMockData()
    }
    
    // MARK: - Intent
    func updateScrollOffset(_ offset: CGFloat) {
        state.scrollOffset = offset
    }
    
    func refreshScores() {
        // 실제 앱에서는 API 호출
        setupMockData()
    }
    
    // MARK: - Private Methods
    private func setupMockData() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        state.currentDate = formatter.string(from: Date())
        
        // 스크린샷과 동일한 데이터
        state.feelingScore = ScoreData(
            title: "Feeling Score",
            subtitle: "Points for speaking freely and confidently.",
            score: 85,
            color: .green,
            chartType: .line
        )
        
        state.fillingScore = ScoreData(
            title: "Filling Score",
            subtitle: "Points for accuracy of the sentences.",
            score: 67,
            color: .blue,
            chartType: .arc
        )
        
        state.isFillingScoreRising = true
    }
}