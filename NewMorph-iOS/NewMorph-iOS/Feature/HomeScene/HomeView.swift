//
//  HomeView.swift
//  NewMorph-iOS
//
//  Created by mini on 8/24/25.
//

import SwiftUI
import SwiftData

public enum Subscene { case question, calendar }

struct HomeView: View {
    @Environment(NavigationRouter.self) private var router
    @Environment(\.modelContext) private var context
    @Environment(AppContainer.self) private var container

    @State private var month = MonthContext(
        year: Calendar.current.component(.year, from: Date()),
        month: 8
    )
    @State private var currentDate: Date = Date()
    @State private var entry: JournalEntry?
    @State private var isSheetPresented: Bool = false

    @State private var subscene: Subscene = .question

    private var hasAnswer: Bool {
        guard let t = entry?.answer.trimmingCharacters(in: .whitespacesAndNewlines)
        else { return false }
        return !t.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            QuestionViewToolBar(
                subscene: $subscene,
                onTapped: { withAnimation(.snappy) {
                    subscene = (subscene == .question) ? .calendar : .question
                }}
            )

            QuestionViewDateBar(
                currentDate: $currentDate,
                day: .constant(Calendar.current.component(.day, from: currentDate)),
                month: month
            )
            .padding(.top, 30)

            ZStack {
                if subscene == .question {
                    QuetionView(
                        entry: entry,
                        onMicTapped: { withAnimation { isSheetPresented = true } }
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
                }

                if subscene == .calendar {
                    CalenderView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                }
            }
            .padding(.horizontal, 20)
            .animation(.snappy, value: subscene)
        }
        .background(.nmBackground1Main)
        .safeAreaInset(edge: .bottom) {
            if hasAnswer {
                NMButton(action: { router.push(.result(date: currentDate)) }, title: "Done")
            }
        }
        .onAppear {
            let day = Calendar.current.component(.day, from: Date())
            currentDate = month.date(day: day)
            loadEntry(for: currentDate)
        }
        .onChange(of: currentDate) { _, newDate in
            loadEntry(for: newDate)
        }
        .nmSheet(isPresented: $isSheetPresented) {
            VoiceInputView { text in
                upsertEntry(for: currentDate, answer: text)
                loadEntry(for: currentDate)
                withAnimation { isSheetPresented = false }
            }
        }
    }
}

// MARK: - 데이터 로딩/업서트
private extension HomeView {
    func loadEntry(for date: Date) {
        let cal = Calendar.current
        let start = cal.startOfDay(for: date)
        let end   = cal.date(byAdding: .day, value: 1, to: start)!

        let predicate = #Predicate<JournalEntry> { e in
            e.date >= start && e.date < end
        }
        let desc = FetchDescriptor<JournalEntry>(predicate: predicate, sortBy: [.init(\.date)])
        do {
            if let existingEntry = try context.fetch(desc).first {
                entry = existingEntry
            } else {
                // 오늘 날짜의 entry가 없으면 랜덤 질문으로 임시 entry 생성 (답변은 빈 문자열)
                let randomQuestion = container.getRandomQuestionUseCase.execute()
                let tempEntry = JournalEntry(date: date, prompt: randomQuestion, answer: "")
                entry = tempEntry
                // 아직 context에는 insert하지 않음 - 사용자가 답변을 입력할 때 insert
            }
        } catch {
            print("SwiftData fetch error: \(error)")
            entry = nil
        }
    }

    func upsertEntry(for date: Date, answer: String) {
        let cal = Calendar.current
        let start = cal.startOfDay(for: date)
        let end   = cal.date(byAdding: .day, value: 1, to: start)!
        let predicate = #Predicate<JournalEntry> { e in
            e.date >= start && e.date < end
        }
        let desc = FetchDescriptor<JournalEntry>(predicate: predicate, sortBy: [.init(\.date)])

        do {
            if let existing = try context.fetch(desc).first {
                existing.answer = answer
                entry = existing
            } else {
                // 새로운 entry 생성 - 이미 entry에 있는 prompt 사용 (loadEntry에서 설정된 랜덤 질문)
                let prompt = entry?.prompt ?? container.getRandomQuestionUseCase.execute()
                let new = JournalEntry(date: date, prompt: prompt, answer: answer)
                context.insert(new)
                entry = new
            }
            try context.save()
        } catch {
            print("SwiftData save error: \(error)")
        }
    }
}

#Preview {
    HomeView()
}
