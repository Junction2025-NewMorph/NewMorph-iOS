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
        // 같은 날(연/월/일 동일)인 항목만 가져오도록 predicate
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
