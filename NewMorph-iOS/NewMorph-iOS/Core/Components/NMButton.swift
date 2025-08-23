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
//                .font(.titleSemiBold16)
//                .padding(.vertical, 16)
//                .frame(maxWidth: .infinity, maxHeight: 56)
//                .foregroundStyle(.ffipBackground1Main)
//                .background(.ffipGrayscale1)
//                .cornerRadius(8)
        }
//        .padding(.horizontal, 20)
//        .padding(.vertical, 12)
    }
}

#Preview {
    NMButton(
        action: {},
        title: "우리가 우승 버튼"
    )
}
