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
        case .demo:
            let viewModel = DemoViewModel(useCase: container.normalizeEnglishUseCase)
            DemoView(viewModel: viewModel)
        case .expression(let date):
            let viewModel = ExpressionViewModel(
                useCase: container.normalizeEnglishUseCase,
                targetDate: date
            )
            ExpressionView(viewModel: viewModel)
        case .speakingResult:
            let speakingResultVM = SpeakingResultViewModel()
            let expressionVM = ExpressionViewModel(
                useCase: container.normalizeEnglishUseCase,
                targetDate: Date()
            )
            ScrollableSpeakingResultView(speakingResultViewModel: speakingResultVM, expressionViewModel: expressionVM)
        case .question:
            QuetionView(entry: nil, onMicTapped: {})
        case .calender:
            CalenderView()
        case .result(let date):
            let viewModel = ExpressionViewModel(
                useCase: container.normalizeEnglishUseCase,
                targetDate: date
            )
            ExpressionView(viewModel: viewModel)
        }
    }
}

#Preview {
    NavigationHostView()
        .environment(NavigationRouter())
}
