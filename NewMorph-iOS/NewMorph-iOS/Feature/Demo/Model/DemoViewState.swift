//
//  State.swift
//  NewMorph-iOS
//
//  Created by OneThing on 8/23/25.
//
import Foundation

struct DemoViewState {
    var input: String = "I went to New York 지하철, but 노선이 헷갈려서 I'm lost."
    var variants: EnglishExpressions? = nil
    var isLoading: Bool = false
    var error: String? = nil
}

public struct EnglishExpressions: Decodable {
    public let friend: String
    public let family: String
    public let third: String  // (auto) formal or meme/humor
}
