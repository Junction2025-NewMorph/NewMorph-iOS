//
//  State.swift
//  NewMorph-iOS
//
//  Created by OneThing on 8/23/25.
//
import Foundation

struct DemoViewState {
    var input: String =
        "I always watch bro라고 말하는 고양이 again and again."
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
