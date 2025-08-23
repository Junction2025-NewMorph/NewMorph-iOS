//
//  QuestionViewToolBar.swift
//  NewMorph-iOS
//
//  Created by mini on 8/23/25.
//

import SwiftUI

struct QuestionViewToolBar: View {
    var body: some View {
        HStack {
            Text("BlahBlah")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(Color(hue: 0.44, saturation: 0.63, brightness: 0.72)) // mint-ish
                .shadow(radius: 0.5)
            
            Spacer()
            
            Button {
                // TODO: 달력 화면 이동 등
            } label: {
                Image(systemName: "calendar")
                    .font(.title3)
                    .foregroundStyle(.primary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
}

#Preview {
    QuestionViewToolBar()
}
