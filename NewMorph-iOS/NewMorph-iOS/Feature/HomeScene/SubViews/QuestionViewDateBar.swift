//
//  QuestionViewDateBar.swift
//  NewMorph-iOS
//
//  Created by mini on 8/23/25.
//

import SwiftUI

struct QuestionViewDateBar: View {
    @Binding var subscene: Subscene
    @Binding var currentDate: Date
    @Binding var day: Int
    let month: MonthContext   // 사용은 안 하지만, 외부 인터페이스 유지

    var body: some View {
        HStack {
            Button { move(-1) } label: { Image(.icnPlayArrowLeft) }
                .padding(.leading, 8)

            Spacer()

            Text(dateTitle(currentDate, mode: subscene))
                .font(.custom(FontName.pretendardSemiBold.rawValue, size: 16))
                .foregroundStyle(.nmGrayscale1)

            Spacer()

            Button { move(1) } label: { Image(.icnPlayArrowRight) }
                .padding(.trailing, 8)
        }
        .padding(.horizontal, 20)
    }
}

private extension QuestionViewDateBar {
    /// 좌우 이동: search는 '일' 단위, calendar는 '월' 단위
    func move(_ delta: Int) {
        switch subscene {
        case .question: moveDay(delta)
        case .calendar: moveMonth(delta)
        }
    }

    func moveDay(_ delta: Int) {
        let cal = Calendar.current
        let nowDay = cal.component(.day, from: currentDate)
        let nextDay = nowDay + delta

        let range = cal.range(of: .day, in: .month, for: currentDate) ?? 1..<32
        let lastDay = range.upperBound - 1
        let clamped = max(range.lowerBound, min(nextDay, lastDay))

        var comps = cal.dateComponents([.year, .month, .day], from: currentDate)
        comps.day = clamped
        guard let nextDate = cal.date(from: comps) else { return }

        withAnimation(.snappy) {
            currentDate = nextDate
            day = clamped
        }
    }

    func moveMonth(_ delta: Int) {
        let cal = Calendar.current
        guard let movedMonthDate = cal.date(byAdding: .month, value: delta, to: currentDate) else { return }

        let range = cal.range(of: .day, in: .month, for: movedMonthDate) ?? 1..<32
        let lastDay = range.upperBound - 1
        let clampedDay = max(range.lowerBound, min(day, lastDay))

        var comps = cal.dateComponents([.year, .month, .day], from: movedMonthDate)
        comps.day = clampedDay
        guard let nextDate = cal.date(from: comps) else { return }

        withAnimation(.snappy) {
            currentDate = nextDate
            day = clampedDay
        }
    }

    func dateTitle(_ date: Date, mode: Subscene) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = (mode == .question) ? "MMM d" : "MMM"
        return f.string(from: date)
    }
}
