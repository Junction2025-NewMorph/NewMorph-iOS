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
        HStack(spacing: 16) {
            Button {
                moveDay(-1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 6)
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            Text(dateTitle(currentDate))
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.primary)
                .contentTransition(.numericText())
                .monospacedDigit()
            
            Spacer()
            
            Button {
                moveDay(1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 6)
            }
            .buttonStyle(.plain)
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
        let cal = Calendar.current
        let m = cal.component(.month, from: date)
        let d = cal.component(.day, from: date)
        return String(format: "%02d월 %02d일", m, d)
    }
}
