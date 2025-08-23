//
//  ExpressionViewModel.swift
//  NewMorph-iOS
//
//  Created by OneThing on 8/23/25.
//

import Combine
import Foundation

@MainActor
final class ExpressionViewModel: ObservableObject {
    
    @Published private(set) var state = ExpressionViewState()
    
    private let useCase: NormalizeEnglishUseCase
    
    init(useCase: NormalizeEnglishUseCase) {
        self.useCase = useCase
        // 초기 데이터 설정 (스크린샷의 예시 텍스트)
        state.originalText = "I just finished Crash Landing on You. I liked it a lot — some parts were kinda cringy, but overall it was super fun"
        state.translatedText = "I just finished 사랑의 불시착 and I really liked it, some part was 조금 오글거려 but 여전히 재밌었어!"
    }
    
    // MARK: - Intent
    func updateOriginalText(_ text: String) {
        state.originalText = text
    }
    
    func updateTranslatedText(_ text: String) {
        state.translatedText = text
    }
    
    func selectMode(_ mode: ExpressionMode) {
        state.selectedMode = mode
    }
    
    func generateExpressions() async {
        guard !state.originalText.isEmpty else { return }
        
        state.isLoading = true
        state.error = nil
        defer { state.isLoading = false }
        
        do {
            let result = try await useCase.execute(state.originalText)
            state.expressions = EnglishExpressionsMapper.map(from: result)
        } catch {
            state.error = error.localizedDescription
        }
    }
    
    func saveExpression() async {
        // Save 기능 구현
        // 실제 앱에서는 저장 로직을 여기에 구현
        print("Saving expression: \(state.originalText)")
    }
    
    func clearError() {
        state.error = nil
    }
    
    // MARK: - Helper Methods
    func getExpressionForMode(_ mode: ExpressionMode) -> String {
        guard let expressions = state.expressions else {
            return "Loading..."
        }
        
        switch mode {
        case .natural:
            return expressions.natural
        case .friends:
            return expressions.friend
        case .family:
            return expressions.family
        case .formal:
            return expressions.third
        }
    }
}