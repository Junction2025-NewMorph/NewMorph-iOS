//
//  QuestionViewToolBar.swift
//  NewMorph-iOS
//
//  Created by mini on 8/23/25.
//

import SwiftUI

struct QuestionViewToolBar: View {
    @Binding var subscene: Subscene

    let onTapped: () -> Void
    
    var body: some View {
        HStack {
            Image(.mainLogo)
            
            Spacer()
            
            Button {
                onTapped()
            } label: {
                Image(subscene == .question ? .icnCalender : .icnHome)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }
}
