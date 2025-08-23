import SwiftUI
import SwiftData

struct QuetionView: View {
    @Environment(NavigationRouter.self) private var router
    @Environment(\.modelContext) private var context

    @Bindable var viewModel = QuestionViewModel()

    @State private var month = MonthContext(
        year: Calendar.current.component(.year, from: Date()),
        month: 8
    )
    @State private var day: Int = 23
    @State private var currentDate: Date = Date()

    @State private var isSheetPresented: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            QuestionViewToolBar(
                onCalenderTapped: { router.push(.calender) }
            )

            QuestionViewDateBar(
                currentDate: $currentDate,
                day: $day,
                month: month
            )
            .padding(.top, 30)

            VStack(spacing: 43) {
                QuestionViewTitle(qustionTitle: "What’s the last\nTV show you watched?")
                    .padding(.top, 20)
                
                QuestionViewCard(currentDate: $currentDate)
            }
            .padding(.horizontal, 20)
            .ignoresSafeArea(.all)
        }
        .background(.nmBackground1Main)
        .overlay(alignment: .bottom) {
            Button(
                action: { withAnimation { isSheetPresented = true } }
            ) {
                Image(.imgMicButton)
            }
            .padding(.bottom, 28)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .onAppear {
            currentDate = month.date(day: day)
        }
        .animation(.snappy, value: currentDate)
        .nmSheet(isPresented: $isSheetPresented) {
            VoiceInputView { text in
                upsertEntry(for: currentDate, answer: text)
                withAnimation { isSheetPresented = false }
            }
        }
    }
}

private extension QuetionView {
    func upsertEntry(for date: Date, answer: String) {
        let cal = Calendar.current
        let start = cal.startOfDay(for: date)
        let end = cal.date(byAdding: .day, value: 1, to: start)!

        let predicate = #Predicate<JournalEntry> { e in
            e.date >= start && e.date < end
        }
        let desc = FetchDescriptor<JournalEntry>(predicate: predicate, sortBy: [.init(\.date)])
        do {
            if let existing = try context.fetch(desc).first {
                existing.answer = answer
            } else {
                let new = JournalEntry(date: date, prompt: "최근 유튜브?", answer: answer)
                context.insert(new)
            }
            try context.save()
        } catch {
            print("SwiftData save error: \(error)")
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: JournalEntry.self, configurations: config)
    let ctx = container.mainContext
    
    // Seed: 8월 22~24일 예시 데이터
    let cal = Calendar.current
    func makeDate(_ day: Int) -> Date {
        let y = cal.component(.year, from: Date())
        let comps = DateComponents(year: y, month: 8, day: day)
        return cal.date(from: comps)!
    }
    if try! ctx.fetch(FetchDescriptor<JournalEntry>()).isEmpty {
        ctx.insert(JournalEntry(date: makeDate(22),
                                prompt: "최근 유튜브?",
                                answer: "어제 ‘iOS 18 Live Activities’ 영상 봤어"))
        ctx.insert(JournalEntry(date: makeDate(23),
                                prompt: "최근 유튜브?",
                                answer: "SwiftData 튜토리얼 채널 시청"))
        ctx.insert(JournalEntry(date: makeDate(24),
                                prompt: "최근 유튜브?",
                                answer: "블라블라: 영어 쉐도잉 영상"))
        try! ctx.save()
    }
    
    return QuetionView()
        .modelContainer(container)
        .environment(NavigationRouter())
}
