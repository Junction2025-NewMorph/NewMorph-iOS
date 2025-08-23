//
//  QuestionViewToolBar.swift
//  NewMorph-iOS
//
//  Created by mini on 8/23/25.
//

import SwiftUI

struct QuestionViewToolBar: View {
    let onCalenderTapped: () -> Void
    
    var body: some View {
        HStack {
            Image(.mainLogo)
            
            Spacer()
            
            Button {
                onCalenderTapped()
            } label: {
                Image(.icnCalender)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }
}

#Preview {
    QuestionViewToolBar(onCalenderTapped: {})
}
