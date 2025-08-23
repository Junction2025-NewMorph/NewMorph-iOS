//
//  State.swift
//  NewMorph-iOS
//
//  Created by OneThing on 8/23/25.
//
import Foundation

struct DemoViewState {
    var input: String =
        "I ate egg sandwich. I wanted 오므라이스 and 과일주스 but 시간 없어서 I can't eat."
    var variants: EnglishExpressions? = nil
    var isLoading: Bool = false
    var error: String? = nil
}

public struct EnglishExpressions: Decodable {
    public let natural: String
    public let friend: String
    public let family: String
    public let third: String  // (auto) formal or meme/humor
}
