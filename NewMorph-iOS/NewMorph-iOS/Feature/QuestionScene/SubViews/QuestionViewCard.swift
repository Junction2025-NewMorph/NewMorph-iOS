//
//  QuestionViewCard.swift
//  NewMorph-iOS
//
//  Created by mini on 8/23/25.
//

import SwiftData
import SwiftUI

struct QuestionViewCard: View {
    @Binding var currentDate: Date

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "asterisk.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 86, height: 86)
                .foregroundStyle(.black)
                .padding(.top, 18)
            
            DayEntryView(date: currentDate)
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.white)
                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
        )
        .padding(.top, 8)
    }
}

struct DayEntryView: View {
    @Environment(\.modelContext) private var context
    @Query private var entries: [JournalEntry]
    
    init(date: Date) {
        let cal = Calendar.current
        let start = cal.startOfDay(for: date)
        let end = cal.date(byAdding: .day, value: 1, to: start)!
        let predicate = #Predicate<JournalEntry> { e in
            e.date >= start && e.date < end
        }
        _entries = Query(filter: predicate, sort: \.date)
    }
    
    var body: some View {
        if let entry = entries.first {
            VStack(alignment: .center, spacing: 8) {
                Text(entry.answer.isEmpty ? "답변을 블라블라해보세요" : entry.answer)
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(entry.answer.isEmpty ? .secondary : .primary)
            }
            .frame(maxWidth: .infinity)
        } else {
            Text("답변을 블라블라해보세요")
                .font(.callout)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

#Preview("With Entry (Today)") {
    // 1) 메모리 전용 컨테이너
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: JournalEntry.self, configurations: config)
    let ctx = container.mainContext

    // 2) 미리보기용 날짜 & 더미 데이터
    let cal = Calendar.current
    let today = cal.startOfDay(for: Date())

    // 비어있으면 하나 삽입
    if (try? ctx.fetch(FetchDescriptor<JournalEntry>()))?.isEmpty ?? true {
        ctx.insert(
            JournalEntry(
                date: today,
                prompt: "최근에 본 TV쇼?",
                answer: "어제 ‘The Bear’ 시즌 3 1화 봤어. 연출 미쳤다! 어제 ‘The Bear’ 시즌 3 1화 봤어. 연출 미쳤다! 어제 ‘The Bear’ 시즌 3 1화 봤어. 연출 미쳤다!어제 ‘The Bear’ 시즌 3 1화 봤어. 연출 미쳤다!어제 ‘The Bear’ 시즌 3 1화 봤어. 연출 미쳤다!어제 ‘The Bear’ 시즌 3 1화 봤어. 연출 미쳤다!어제 ‘The Bear’ 시즌 3 1화 봤어. 연출 미쳤다!어제 ‘The Bear’ 시즌 3 1화 봤어. 연출 미쳤다!어제 ‘The Bear’ 시즌 3 1화 봤어. 연출 미쳤다!어제 ‘The Bear’ 시즌 3 1화 봤어. 연출 미쳤다!어제 ‘The Bear’ 시즌 3 1화 봤어. 연출 미쳤다!어제 ‘The Bear’ 시즌 3 1화 봤어. 연출 미쳤다!어제 ‘The Bear’ 시즌 3 1화 봤어. 연출 미쳤다!어제 ‘The Bear’ 시즌 3 1화 봤어. 연출 미쳤다!어제 ‘The Bear’ 시즌 3 1화 봤어. 연출 미쳤다!어제 ‘The Bear’ 시즌 3 1화 봤어. 연출 미쳤다!어제 ‘The Bear’ 시즌 3 1화 봤어. 연출 미쳤다!"
            )
        )
        try! ctx.save()
    }

    // 3) 바인딩 넘겨 렌더
    @State var currentDate: Date = today

    return QuestionViewCard(currentDate: $currentDate)
        .padding()
        .background(Color(.systemGroupedBackground))
        .modelContainer(container)
}

#Preview("Empty State (Tomorrow)") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: JournalEntry.self, configurations: config)

    let cal = Calendar.current
    let tomorrow = cal.date(byAdding: .day, value: 1, to: cal.startOfDay(for: Date()))!

    @State var currentDate: Date = tomorrow

    return QuestionViewCard(currentDate: $currentDate)
        .padding()
        .background(Color(.systemGroupedBackground))
        .modelContainer(container)
}
