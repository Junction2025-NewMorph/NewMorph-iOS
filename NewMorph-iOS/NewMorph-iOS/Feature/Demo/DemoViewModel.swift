//
//  DemoViewModel.swift
//  NewMorph-iOS
//
//  Created by OneThing on 8/23/25.
//

import Combine
import Foundation

@MainActor
final class DemoViewModel: ObservableObject {

    // 이제 struct 대신 외부에서 분리된 DemoViewState 사용
    @Published private(set) var state = DemoViewState()

    private let useCase: NormalizeEnglishUseCase

    init(useCase: NormalizeEnglishUseCase) {
        self.useCase = useCase
    }

    // MARK: - Intent
    func updateInput(_ text: String) {
        state.input = text
    }

    func execute() async throws -> EnglishVariants {
        state.isLoading = true
        state.error = nil
        defer { state.isLoading = false }

        let result = try await useCase.execute(state.input)
        state.variants = EnglishExpressionsMapper.map(from: state.input)
        return result
    }

    func clearError() {
        state.error = nil
    }
}
