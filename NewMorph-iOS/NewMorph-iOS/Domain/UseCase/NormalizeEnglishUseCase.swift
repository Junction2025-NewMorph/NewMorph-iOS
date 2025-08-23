//
//  NormalizeEnglishUseCase.swift
//  NewMorph-iOS
//
//  Created by OneThing on 8/23/25.
//

import Foundation

/// 혼합 한/영 문장을 받아 GPT를 통해
/// friend / family / third 3가지 톤의 영어 문장으로 변환하는 유즈케이스
public final class NormalizeEnglishUseCase {
    private let client: OpenAIClient

    public init(client: OpenAIClient) {
        self.client = client
    }

    /// - Parameter mixedText: 한/영 혼합 문장
    /// - Returns: friend, family, third 톤을 포함한 EnglishVariants
    public func execute(_ mixedText: String) async throws -> EnglishVariants {
        // 최소한의 입력 검증
        let trimmed = mixedText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            throw NSError(
                domain: "NormalizeEnglishUseCase",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "입력이 비어 있습니다."]
            )
        }

        // 실제 변환은 OpenAIClient에 위임
        return try await client.generateEnglishVariants(mixedText: trimmed)
    }
}
