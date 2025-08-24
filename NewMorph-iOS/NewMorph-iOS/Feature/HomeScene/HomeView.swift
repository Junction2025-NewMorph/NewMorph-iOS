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
                subscene: $subscene,
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
            
            if hasAnswer && subscene == .question {
                NMButton(action: { router.push(.result) }, title: "Done")
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                    .zIndex(0)
            }
        }
        .background(.nmBackground1Main)
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
                triggerHapticFeedback()
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
            entry = try context.fetch(desc).first
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
                let new = JournalEntry(date: date, prompt: "최근 유튜브?", answer: answer)
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
        .environment(NavigationRouter())
        .modelContainer(for: JournalEntry.self)
}
