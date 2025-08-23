//
//  NavigationHostView.swift
//  NewMorph-iOS
//
//  Created by mini on 8/22/25.
//

import SwiftUI

struct NavigationHostView: View {
    @Environment(NavigationRouter.self) private var router
    @Environment(AppContainer.self) private var container

    var body: some View {
        NavigationStack(path: router.pathBinding) {
            ContentView()
                .navigationDestination(for: AppRoute.self) { route in
                    destinationView(for: route)
                }
        }
    }

    @ViewBuilder
    private func destinationView(for route: AppRoute) -> some View {
        switch route {
        case .home:
            ContentView()
        case .demo:
            let viewModel = DemoViewModel(useCase: container.normalizeEnglishUseCase)
            DemoView(viewModel: viewModel)
        }
    }
}

#Preview {
    NavigationHostView()
        .environment(NavigationRouter())
}
