//
//  NMLoadingView.swift
//  NewMorph-iOS
//
//  Created by mini on 8/24/25.
//

import SwiftUI

enum CalenderDimmedStyle {
    case missed, notYet
    var title: String {
        switch self {
        case .missed:
            "Oh no!\nYou Missed it"
        case .notYet:
            "Not yet,\nWait for it!"
        }
    }
}

struct CalenderDimmedView: View {
    let style: CalenderDimmedStyle
    
    var body: some View {
        VStack {
            if style == .missed {
                Image(.mainCharacterSad)
            }
                        
            Text(style.title)
                .font(.custom(FontName.jejudoldam.rawValue, size: 32))
                .foregroundStyle(.nmGrayscale1)
                .multilineTextAlignment(.center)
                .lineHeight(.multiple(factor: 1.6))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
    }
}
