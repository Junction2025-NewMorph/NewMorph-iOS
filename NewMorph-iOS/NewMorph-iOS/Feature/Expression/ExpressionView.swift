//
//  ExpressionView.swift
//  NewMorph-iOS
//
//  Created by OneThing on 8/23/25.
//

import SwiftUI
import SwiftData

struct ExpressionView: View {
    @StateObject private var viewModel: ExpressionViewModel
    @Environment(\.modelContext) private var modelContext
    
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
                    VStack(spacing: 20) {
                        // Main content card
                        VStack(alignment: .leading, spacing: 16) {
                            // Original text section
                            Text(viewModel.state.originalText)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                                .lineSpacing(4)

                            // Thin divider under the original text
                            Rectangle()
                                .fill(Color("nmGrayscale4").opacity(0.35))
                                .frame(height: 1)
                                .padding(.vertical, 2)

                            // Translated text box (rounded light background inside card)
                            Text(viewModel.state.translatedText)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                                .lineSpacing(2)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color("nmGrayscale5"))
                                )
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.white)
                                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 2)
                        )

                        // "In other cases" section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("In other cases")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            // Horizontal scrolling cards
                            ExpressionCardsScrollView(viewModel: viewModel)
                        }
                        
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
            .background(Color("nmGrayscale1"))
                            .cornerRadius(0)
                    }
                }
            }
            .background(Color(.nmBackgroundResult))
        }
        .navigationBarHidden(true)
        .task {
            viewModel.loadJournalEntry(modelContext: modelContext)
            await viewModel.generateExpressions()
        }
    }
}

#Preview {
    let container = AppContainer.mock()
    let viewModel = ExpressionViewModel(
        useCase: container.normalizeEnglishUseCase,
        targetDate: Date()
    )
    
    ExpressionView(viewModel: viewModel)
        .modelContainer(try! ModelContainer(for: JournalEntry.self))
}
