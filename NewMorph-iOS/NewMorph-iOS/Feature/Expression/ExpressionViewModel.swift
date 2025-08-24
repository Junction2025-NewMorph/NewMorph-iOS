//
//  ExpressionViewModel.swift
//  NewMorph-iOS
//
//  Created by OneThing on 8/23/25.
//

import Combine
import Foundation
import SwiftData

@MainActor
final class ExpressionViewModel: ObservableObject {
    
    @Published private(set) var state = ExpressionViewState()
    
    private let useCase: NormalizeEnglishUseCase
    private let targetDate: Date
    
    init(useCase: NormalizeEnglishUseCase, targetDate: Date = Date()) {
        self.useCase = useCase
        self.targetDate = targetDate
        
        // 기본값 설정 (JournalEntry가 로드되기 전까지)
        state.originalText = "I just finished Crash Landing on You. I liked it a lot — some parts were kinda cringy, but overall it was super fun"
        state.translatedText = "I just finished 사랑의 불시착 and I really liked it, some part was 조금 오글거려 but 여전히 재밌었어!"
    }
    
    // MARK: - Data Loading
    func loadJournalEntry(modelContext: ModelContext) {
        let cal = Calendar.current
        let start = cal.startOfDay(for: targetDate)
        let end = cal.date(byAdding: .day, value: 1, to: start)!
        
        let predicate = #Predicate<JournalEntry> { entry in
            entry.date >= start && entry.date < end
        }
        let descriptor = FetchDescriptor<JournalEntry>(predicate: predicate, sortBy: [.init(\.date)])
        
        do {
            if let journalEntry = try modelContext.fetch(descriptor).first {
                // JournalEntry의 answer를 originalText와 userSpeechText로 사용 
                state.originalText = journalEntry.answer.isEmpty ? state.originalText : journalEntry.answer
                state.userSpeechText = journalEntry.answer.isEmpty ? state.userSpeechText : journalEntry.answer
            }
        } catch {
            print("JournalEntry fetch error: \(error)")
        }
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
    
    // MARK: - Text Comparison Methods
    func updateCorrectText(_ text: String) {
        state.correctText = text
    }
    
    func updateUserSpeechText(_ text: String) {
        state.userSpeechText = text
    }
    
    func updateExpressions(_ expressions: EnglishExpressions) {
        state.expressions = expressions
    }
    
    func getHighlightedUserSpeech() -> AttributedString {
        guard !state.userSpeechText.isEmpty, !state.correctText.isEmpty else {
            return AttributedString(state.userSpeechText)
        }
        
        // 기존 방식 유지 (correctText와 비교)
        return TextDiffUtility.highlightedUserAttributedText(
            userText: state.userSpeechText,
            correctText: state.correctText
        )
    }
    
    // MARK: - Natural Text Display Methods (New TextDiffer 사용)
    func getHighlightedNaturalText() -> AttributedString {
        guard let expressions = state.expressions, !state.userSpeechText.isEmpty else {
            return AttributedString(getExpressionForMode(.natural))
        }
        
        // 특수문자를 필터링한 토큰으로 비교
        let originalTokens = TextTokenizer.tokenizeForDiff(state.userSpeechText)
        let naturalTokens = TextTokenizer.tokenizeForDiff(expressions.natural)
        let operations = TextDiffer.diff(original: originalTokens, natural: naturalTokens)
        
        return AttributedStringBuilder.buildNaturalAttributed(from: operations)
    }
    
    func getHighlightedOriginalText() -> AttributedString {
        guard let expressions = state.expressions, !state.userSpeechText.isEmpty else {
            return AttributedString(state.userSpeechText)
        }
        
        // 특수문자를 필터링한 토큰으로 비교
        let originalTokens = TextTokenizer.tokenizeForDiff(state.userSpeechText)
        let naturalTokens = TextTokenizer.tokenizeForDiff(expressions.natural)
        let operations = TextDiffer.diff(original: originalTokens, natural: naturalTokens)
        
        return AttributedStringBuilder.buildOriginalAttributed(from: operations)
    }
    
    // MARK: - 디버깅용 메서드
    func printTextComparison() {
        guard let expressions = state.expressions, !state.userSpeechText.isEmpty else { return }
        
        print("🔍 특수문자 필터링 적용된 비교:")
        let originalTokens = TextTokenizer.tokenizeForDiff(state.userSpeechText)
        let naturalTokens = TextTokenizer.tokenizeForDiff(expressions.natural)
        
        print("원문 필터링된 토큰: \(originalTokens.map { "\"\($0.text)\"" }.joined(separator: ", "))")
        print("자연 필터링된 토큰: \(naturalTokens.map { "\"\($0.text)\"" }.joined(separator: ", "))")
        
        AttributedStringBuilder.printDifferences(
            original: state.userSpeechText,
            natural: expressions.natural
        )
    }
}
