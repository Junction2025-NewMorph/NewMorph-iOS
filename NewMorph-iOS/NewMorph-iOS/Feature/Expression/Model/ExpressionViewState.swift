//
//  ExpressionViewState.swift
//  NewMorph-iOS
//
//  Created by OneThing on 8/23/25.
//

import Foundation

struct ExpressionViewState {
    var originalText: String = ""
    var translatedText: String = ""
    var expressions: EnglishExpressions? = nil
    var isLoading: Bool = false
    var error: String? = nil
    var selectedMode: ExpressionMode = .natural
}

enum ExpressionMode: CaseIterable {
    case natural
    case friends
    case family
    case formal
    
    var title: String {
        switch self {
        case .natural:
            return "Natural"
        case .friends:
            return "Friends Mode"
        case .family:
            return "Family Mode"
        case .formal:
            return "Formal"
        }
    }
    
    var description: String {
        switch self {
        case .natural:
            return "Natural expression"
        case .friends:
            return "Casual with friends"
        case .family:
            return "Family conversation"
        case .formal:
            return "Formal expression"
        }
    }
    
    var color: String {
        switch self {
        case .natural:
            return "blue"
        case .friends:
            return "green"
        case .family:
            return "purple"
        case .formal:
            return "gray"
        }
    }
}