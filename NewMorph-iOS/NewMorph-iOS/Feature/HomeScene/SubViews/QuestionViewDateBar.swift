//
//  QuestionViewDateBar.swift
//  NewMorph-iOS
//
//  Created by mini on 8/23/25.
//

import SwiftUI

struct QuestionViewDateBar: View {
    @Binding var currentDate: Date
    @Binding var day: Int
    let month: MonthContext
    
    var body: some View {
        HStack {
            Button {
                moveDay(-1)
            } label: {
                Image(.icnPlayArrowLeft)
            }
            .padding(.leading, 8)
            
            Spacer()
            
            Text(dateTitle(currentDate))
                .font(.custom(FontName.pretendardSemiBold.rawValue, size: 16))
                .foregroundStyle(.nmGrayscale1)
            
            Spacer()
            
            Button {
                moveDay(1)
            } label: {
                Image(.icnPlayArrowRight)
            }
            .padding(.trailing, 8)
        }
        .padding(.horizontal, 20)
    }
}

private extension QuestionViewDateBar {
    func moveDay(_ delta: Int) {
        let cal = Calendar.current
        let dayNow = cal.component(.day, from: currentDate)
        let nextDay = dayNow + delta
        let clamped = month.clampedDay(nextDay)
        let nextDate = month.date(day: clamped)
        withAnimation(.snappy) {
            currentDate = nextDate
            day = clamped
        }
    }
    
    func dateTitle(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}
