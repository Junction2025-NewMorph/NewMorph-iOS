//
//  EnglishExpressionsMapper.swift
//  NewMorph-iOS
//
//  Created by OneThing on 8/23/25.
//
import Foundation

struct EnglishExpressionsMapper {
    static func map(from input: EnglishVariants) -> EnglishExpressions {
        // 예시 변환 로직 (실제 구현에서는 AI 응답을 매핑)
        return EnglishExpressions(
            natural: input.natural,
            friend: input.friend,
            family: input.family,
            third: input.third
        )
    }
}
