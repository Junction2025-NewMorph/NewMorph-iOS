//
//  NavigationHostView.swift
//  NewMorph-iOS
//
//  Created by mini on 8/22/25.
//

import SwiftUI

struct NavigationHostView: View {
    @Environment(NavigationRouter.self) private var router

    var body: some View {
        NavigationStack(path: router.pathBinding) {
            HomeView()
                .navigationDestination(for: AppRoute.self) { route in
                    destinationView(for: route)
                }
        }
    }
    
    @ViewBuilder
    private func destinationView(for route: AppRoute) -> some View {
        switch route {
        case .home:
            HomeView()
        case .question:
            QuetionView(entry: nil, onMicTapped: {})
        case .calender:
            CalenderView()
        case .result:
            ResultView()
        }
    }
}

#Preview {
    NavigationHostView()
        .environment(NavigationRouter())
}
