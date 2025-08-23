//
//  ExpressionCardsScrollView.swift
//  NewMorph-iOS
//
//  Created by OneThing on 8/23/25.
//

import SwiftUI

struct ExpressionCardsScrollView: View {
    @ObservedObject var viewModel: ExpressionViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(ExpressionMode.allCases, id: \.self) { mode in
                    ExpressionCard(
                        mode: mode,
                        expression: viewModel.getExpressionForMode(mode),
                        isSelected: viewModel.state.selectedMode == mode
                    ) {
                        viewModel.selectMode(mode)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

struct ExpressionCard: View {
    let mode: ExpressionMode
    let expression: String
    let isSelected: Bool
    let action: () -> Void
    
    var backgroundColor: Color {
        switch mode {
        case .natural:
            return Color.blue.opacity(0.1)
        case .friends:
            return Color.green.opacity(0.1)
        case .family:
            return Color.purple.opacity(0.1)
        case .formal:
            return Color.gray.opacity(0.1)
        }
    }
    
    var buttonColor: Color {
        switch mode {
        case .natural:
            return Color.blue
        case .friends:
            return Color.green
        case .family:
            return Color.purple
        case .formal:
            return Color.gray
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Mode button
            Button(action: action) {
                Text(mode.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(buttonColor)
                    )
            }
            
            // Expression text
            Text(expression)
                .font(.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: 280, alignment: .topLeading)
        .padding(.all, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? buttonColor : Color.clear, lineWidth: 2)
                )
        )
        .onTapGesture {
            action()
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    let container = AppContainer.mock()
    let viewModel = ExpressionViewModel(useCase: container.normalizeEnglishUseCase, targetDate: Date())
    
    ExpressionCardsScrollView(viewModel: viewModel)
        .padding()
}