//
//  GetRandomQuestionUseCase.swift
//  NewMorph-iOS
//
//  Created by eunsong on 8/24/25.
//
import Foundation

public struct GetRandomQuestionUseCase {
    private let repository: QuestionsRepository
    public init(repository: QuestionsRepository) {
        self.repository = repository
    }

    public func execute() -> String {
        repository.random()
    }
}
