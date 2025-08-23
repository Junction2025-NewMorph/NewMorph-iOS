import SwiftUI
import SwiftData

struct QuetionView: View {
    let entry: JournalEntry?
    var onMicTapped: () -> Void

    private var hasAnswer: Bool {
        guard let t = entry?.answer.trimmingCharacters(in: .whitespacesAndNewlines)
        else { return false }
        return !t.isEmpty
    }

    var body: some View {
        VStack(spacing: 43) {
            QuestionViewTitle(qustionTitle: entry?.prompt ?? "")
                .padding(.top, 20)

            QuestionViewCard(entry: entry ?? JournalEntry(date: Date(), prompt: "", answer: ""))
        }
        .overlay(alignment: .bottom) {
            if !hasAnswer {
                Button(action: onMicTapped) { Image(.imgMicButton) }
                    .padding(.bottom, 28)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
}
