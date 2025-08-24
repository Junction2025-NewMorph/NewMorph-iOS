//
//  QuestionViewCard.swift
//  NewMorph-iOS
//
//  Created by mini on 8/23/25.
//

import SwiftData
import SwiftUI

struct QuestionViewCard: View {
    @Bindable var entry: JournalEntry

    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(.nmBackground2Modal)
                .shadow(color: .black.opacity(0.06), radius: 14, x: 0, y: 0)
                .overlay(alignment: .center) {
                    DayEntryView(text: $entry.answer)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .ignoresSafeArea(.all)

            Image(.mainCharacterBasic)
                .offset(y: -50)
        }
        .padding(.top, 43)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct DayEntryView: View {
    @Binding var text: String
    
    var body: some View {
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            Text("Just Blahblah your reply")
                .font(.custom(FontName.pretendardMedium.rawValue, size: 18))
                .foregroundStyle(.nmGrayscale4)
        } else {
            TextEditor(text: $text)
                .font(.custom(FontName.pretendardRegular.rawValue, size: 16))
                .foregroundStyle(.nmGrayscale2)
                .padding(.top, 68)          
                .padding(.bottom, 20)
                .padding(.horizontal, 28)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .textInputAutocapitalization(.sentences)
                .autocorrectionDisabled(false)
        }
    }
}

#Preview {
    QuestionViewCard(entry: JournalEntry(date: .now, prompt: "d", answer: "d"))
}
