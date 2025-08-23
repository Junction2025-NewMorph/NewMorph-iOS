//
//  NMButton.swift
//  NewMorph-iOS
//
//  Created by mini on 8/22/25.
//

import SwiftUI

struct NMButton: View {
    let action: () -> Void
    let title: String
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom(FontName.pretendardSemiBold.rawValue, size: 18))
                .padding(.top, 19)
                .padding(.bottom, 31)
                .frame(maxWidth: .infinity, maxHeight: 77)
                .foregroundStyle(.nmBackground1Main)
                .background(.nmGrayscale1)
        }
    }
}

#Preview {
    VStack {
        Spacer()
        NMButton(
            action: {},
            title: "우리가 우승 버튼"
        )
    }
    .ignoresSafeArea(.all)
}
