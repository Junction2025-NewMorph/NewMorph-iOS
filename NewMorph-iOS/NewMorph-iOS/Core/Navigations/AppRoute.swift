//
//  AppRoute.swift
//  NewMorph-iOS
//
//  Created by mini on 8/22/25.
//

import Foundation

public enum AppRoute: Hashable {
    case home
    case demo
    case expression(date: Date = Date())
    case speakingResult
    case question
    case calender
    case result(date: Date = Date())
}
