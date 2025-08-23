//
//  SpeakingResultViewState.swift
//  NewMorph-iOS
//
//  Created by OneThing on 8/23/25.
//

import Foundation

struct SpeakingResultViewState {
    var currentDate: String = "August 23, 2025"
    var feelingScore: ScoreData = ScoreData(
        title: "Feeling Score",
        subtitle: "Points for speaking freely and confidently.",
        score: 85,
        color: .green,
        chartType: .line
    )
    var fillingScore: ScoreData = ScoreData(
        title: "Filling Score", 
        subtitle: "Points for accuracy of the sentences.",
        score: 67,
        color: .blue,
        chartType: .arc
    )
    var isFillingScoreRising: Bool = true
    var scrollOffset: CGFloat = 0
}

struct ScoreData {
    let title: String
    let subtitle: String
    let score: Int
    let color: ScoreColor
    let chartType: ChartType
}

enum ScoreColor {
    case green
    case blue
    
    var primary: String {
        switch self {
        case .green: return "green"
        case .blue: return "blue"
        }
    }
    
    var light: String {
        switch self {
        case .green: return "mint"
        case .blue: return "cyan"
        }
    }
}

enum ChartType {
    case line
    case arc
}