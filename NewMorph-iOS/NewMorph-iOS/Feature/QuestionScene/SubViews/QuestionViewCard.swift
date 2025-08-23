//
//  QuestionViewCard.swift
//  NewMorph-iOS
//
//  Created by mini on 8/23/25.
//

import SwiftData
import SwiftUI

struct QuestionViewCard: View {
    let entry: JournalEntry?

    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(.nmBackground2Modal)
                .shadow(color: .black.opacity(0.06), radius: 14, x: 0, y: 0)
                .overlay(alignment: .center) {
                    DayEntryView(entry: entry)
                        .frame(maxWidth: .infinity, alignment: .center)
                }

            Image(.mainCharacterBasic)
                .offset(y: -50)
        }
        .padding(.top, 43)
        .frame(maxWidth: .infinity)
    }
}

struct DayEntryView: View {
    let entry: JournalEntry?

    var body: some View {
        if let entry, !entry.answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            ScrollView {
                Text(entry.answer)
                    .font(.custom(FontName.pretendardRegular.rawValue, size: 16))
                    .foregroundStyle(.nmGrayscale2)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 68)
                    .padding(.bottom, 20)
                    .padding(.horizontal, 28)
            }
            .scrollIndicators(.hidden)
        } else {
            Text("Just Blahblah your reply")
                .font(.custom(FontName.pretendardMedium.rawValue, size: 18))
                .foregroundStyle(.nmGrayscale4)
        }
    }
}
