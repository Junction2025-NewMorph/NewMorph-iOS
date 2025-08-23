//
//  NavigationRouter.swift
//  NewMorph-iOS
//
//  Created by mini on 8/22/25.
//

import SwiftUI
import Observation

@MainActor
@Observable
public final class NavigationRouter {
    public var path = NavigationPath()

    public var pathBinding: Binding<NavigationPath> {
        Binding(get: { self.path }, set: { self.path = $0 })
    }

    public var sheet: AppSheet?
    public var fullScreen: AppFull?

    public init() {}

    public func push(_ route: AppRoute) { path.append(route) }
    public func pop() { if !path.isEmpty { path.removeLast() } }
    public func popToRoot() { path.removeLast(path.count) }

    public func presentSheet(_ s: AppSheet) { sheet = s }
    public func dismissSheet() { sheet = nil }
    public func presentFull(_ f: AppFull) { fullScreen = f }
    public func dismissFull() { fullScreen = nil }
}

// 모달 라우트(원하면 생략 가능)
public enum AppSheet: Hashable { case settings, picker }
public enum AppFull: Hashable { case onboarding }
