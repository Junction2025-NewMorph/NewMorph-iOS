//
//  QuetionViewTitle.swift
//  NewMorph-iOS
//
//  Created by mini on 8/23/25.
//

import SwiftUI

struct QuestionViewTitle: View {
    let qustionTitle: String
    
    var body: some View {
        Text(qustionTitle)
            .font(.custom(FontName.pretendardBold.rawValue, size: 24))
            .foregroundStyle(.nmGrayscale1)
            .frame(maxWidth: .infinity, alignment: .center)
            .multilineTextAlignment(.center)
    }
}

#Preview {
    QuestionViewTitle(qustionTitle: "What’s the last\nTV show you watched?")
}
