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
                        // Natural text section with highlighting (녹색 형광펜으로 다른 부분 표시)
                        Text(viewModel.getHighlightedNaturalText())
                            .font(.title2)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.leading)
                            .lineSpacing(4)
                        
                        // Original user speech with left line (굵게 처리된 다른 부분)
                        HStack(alignment: .top, spacing: 0) {
                            // Left vertical line
                            Rectangle()
                                .fill(Color("nmGrayscale4").opacity(0.6))
                                .frame(width: 4)
                            
                            // Original user speech text
                            Text(viewModel.getHighlightedOriginalText())
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
            
            // 테스트용 데이터 설정 (development only - 실제 앱에서는 API에서 데이터 로드)
            if viewModel.state.expressions == nil {
                let testExpressions = EnglishExpressions(
                    natural: "I just finished Crash Landing on You. I liked it a lot — some parts were kinda cringy, but overall it was super fun",
                    friend: "Just finished Crash Landing on You! Loved it, though some parts were pretty cringy, but still super fun overall",
                    family: "I just finished watching Crash Landing on You. I really enjoyed it, although some scenes were a bit awkward, but it was very entertaining",
                    third: "I have recently completed viewing Crash Landing on You. While certain segments were somewhat awkward, the overall experience was quite enjoyable"
                )
                viewModel.updateExpressions(testExpressions)
            }
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
