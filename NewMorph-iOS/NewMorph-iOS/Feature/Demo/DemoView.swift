//
//  DemoView.swift
//  NewMorph-iOS
//
//  Created by OneThing on 8/23/25.
//

import SwiftUI

struct DemoView: View {
    @StateObject private var viewModel: DemoViewModel

    init(viewModel: DemoViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                inputSection
                actionButton
                errorSection
                resultsSection
            }
            .padding()
        }
    }

    // MARK: - View Components

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("텍스트 입력")
                .font(.headline)

            TextField(
                "입력(한/영 섞인 문장)",
                text: Binding(
                    get: { viewModel.state.input },
                    set: { viewModel.updateInput($0) }
                )
            )
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .disabled(viewModel.state.isLoading)
        }
    }

    private var actionButton: some View {
        Button(action: {
            Task {
                try? await viewModel.execute()
            }
        }) {
            HStack {
                if viewModel.state.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Text("변환 실행")
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
        }
        .buttonStyle(.borderedProminent)
        .disabled(
            viewModel.state.isLoading
                || viewModel.state.input.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ).isEmpty
        )
    }

    @ViewBuilder
    private var errorSection: some View {
        if let error = viewModel.state.error {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)

                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)

                Spacer()

                Button("닫기", action: viewModel.clearError)
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.red.opacity(0.1))
            .cornerRadius(8)
        }
    }

    @ViewBuilder
    private var resultsSection: some View {
        if let variants = viewModel.state.variants {
            VStack(alignment: .leading, spacing: 12) {
                Text("변환 결과")
                    .font(.headline)

                resultRow(title: "친구/DM", value: variants.friend)
                resultRow(title: "가족/지인", value: variants.family)
                resultRow(
                    title: "세 번째(자동 선택: 포멀 또는 밈/유머)",
                    value: variants.third
                )
            }
        }
    }

    private func resultRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(value.isEmpty ? "결과 없음" : value)
                .font(.body)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
        }
    }
}

extension View {
    fileprivate func eraseToAnyView() -> AnyView { AnyView(self) }
}

#Preview {
    let container = AppContainer.mock()
    return DemoView(viewModel: DemoViewModel(useCase: container.useCase))
}
