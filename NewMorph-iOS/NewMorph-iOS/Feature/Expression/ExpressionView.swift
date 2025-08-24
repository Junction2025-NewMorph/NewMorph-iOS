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
    var onClose: (() -> Void)?
    
    init(viewModel: ExpressionViewModel, onClose: (() -> Void)? = nil) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.onClose = onClose
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Top navigation area
            HStack {
                Spacer()
                Button(action: {
                    onClose?()
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
                    VStack(alignment: .leading, spacing: 20) {
                        // Original text section with highlighting
                        Text(viewModel.getHighlightedUserSpeech())
                            .font(.title2)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.leading)
                            .lineSpacing(4)
                        // Translation text with left line (separate card)
                        HStack(alignment: .top, spacing: 0) {
                            // Left vertical line
                            Rectangle()
                                .fill(Color("nmGrayscale4").opacity(0.6))
                                .frame(width: 4)
                            
                            // Translation text
                            Text(viewModel.state.translatedText)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                                .lineSpacing(3)
                                .padding(.leading, 16)
                                .padding(.vertical, 16)
                                .padding(.trailing, 20)
                        }

                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.white)
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                    )
                    .padding(.horizontal, 20)

                    // "In other cases" section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("In other cases")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.top, 4)
                        
                        // Horizontal scrolling cards
                        ExpressionCardsScrollView(viewModel: viewModel)
                    }
                    .padding(20)
                    Spacer(minLength: 100)
                }
            }
            .scrollDisabled(true)  // Disable inner scrolling for parent scroll compatibility
            
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
        .background(Color(.nmBackgroundResult))
        .task {
            viewModel.loadJournalEntry(modelContext: modelContext)
            await viewModel.generateExpressions()
            
            // 테스트용 데이터 설정 (실제 앱에서는 실제 데이터로 대체)
            viewModel.updateUserSpeechText("I just finished Crash Landing on You. I liked it lot — some parts were kinda cringy, but overall it was super fun")
            viewModel.updateCorrectText("I just finished Crash Landing on You. I liked it a lot — some parts were kinda cringy, but overall it was super fun")
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
