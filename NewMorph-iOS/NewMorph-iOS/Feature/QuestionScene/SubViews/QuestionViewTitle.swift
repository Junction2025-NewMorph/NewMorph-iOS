//
//  QuetionViewTitle.swift
//  NewMorph-iOS
//
//  Created by mini on 8/23/25.
//

import SwiftUI

struct QuestionViewTitle: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("최근에 시청한")
                .font(.system(size: 24, weight: .heavy))
                .foregroundStyle(.primary)
            HStack(spacing: 4) {
                Text("유튜브 영상은 뭐야?")
                    .font(.system(size: 24, weight: .heavy))
                    .foregroundStyle(.primary)
                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    QuestionViewTitle()
}
