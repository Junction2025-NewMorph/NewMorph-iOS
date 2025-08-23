//
//  ExpressionView.swift
//  NewMorph-iOS
//
//  Created by OneThing on 8/23/25.
//

import SwiftUI

struct ExpressionView: View {
    @StateObject private var viewModel: ExpressionViewModel
    
    init(viewModel: ExpressionViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Top navigation area
                HStack {
                    Spacer()
                    Button(action: {
                        // Close action
                    }) {
                        Image(systemName: "chevron.up")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                    Spacer()
                }
                .padding(.top, 10)
                .padding(.horizontal, 20)
                
                // Main content
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Original text section
                        VStack(alignment: .leading, spacing: 12) {
                            Text(viewModel.state.originalText)
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal, 20)
                            
                            // Translated text box
                            VStack(alignment: .leading, spacing: 8) {
                                Rectangle()
                                    .fill(Color(.systemGray6))
                                    .frame(height: 4)
                                    .padding(.leading, 20)
                                
                                Text(viewModel.state.translatedText)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.systemGray6))
                                    )
                                    .padding(.horizontal, 20)
                            }
                        }
                        .padding(.top, 30)
                        
                        // "In other cases" section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("In other cases")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 20)
                            
                            // Horizontal scrolling cards
                            ExpressionCardsScrollView(viewModel: viewModel)
                        }
                        .padding(.top, 40)
                        
                        Spacer(minLength: 100)
                    }
                }
                
                // Bottom Save button
                VStack(spacing: 0) {
                    Divider()
                    
                    Button(action: {
                        Task {
                            await viewModel.saveExpression()
                        }
                    }) {
                        Text("Save")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.black)
                            .cornerRadius(0)
                    }
                }
            }
            .background(Color(.systemBackground))
        }
        .navigationBarHidden(true)
        .task {
            await viewModel.generateExpressions()
        }
    }
}

#Preview {
    let container = AppContainer.mock()
    let viewModel = ExpressionViewModel(useCase: container.normalizeEnglishUseCase)
    
    ExpressionView(viewModel: viewModel)
}