//
//  NMLoadingAnimation.swift
//  NewMorph-iOS
//
//  Created by mini on 8/24/25.
//

import SwiftUI

struct NMLoadingAnimation: View {
    @Binding var isAnimating: Bool

    var itemSize: CGFloat = 12
    var spacing: CGFloat = 13
    var phaseDuration: TimeInterval = 0.3
    var accentColor: Color = Color(hue: 0.46, saturation: 0.74, brightness: 0.74)
    var primaryColor: Color = .primary

    @State private var phase: Int = 0

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<4, id: \.self) { i in
                indicator(at: i)
            }
        }
        .animation(.linear(duration: phaseDuration), value: phase)
        .task {
            while true {
                if isAnimating {
                    phase = (phase + 1) % 4
                }
                try? await Task.sleep(for: .seconds(phaseDuration))
            }
        }
    }

    @ViewBuilder
    private func indicator(at index: Int) -> some View {
        Group {
            if index == 2 {
                Circle().fill(accentColor)
            } else {
                Rectangle().fill(primaryColor)
            }
        }
        .frame(width: itemSize, height: itemSize)
        .padding(.bottom, bottomPadding(index: index))
    }

    private func bottomPadding(index: Int) -> CGFloat {
        guard isAnimating else { return 0 } // 안 움직일 때는 바닥에 고정
        let table: [[CGFloat]] = [
            [0, 0, 18, 6],
            [0, 18, 6, 0],
            [18, 6, 0, 0],
            [6, 0, 0, 18]
        ]
        return table[index][phase]
    }
}

//#Preview {
//    StatefulPreviewWrapper(true) { isAnimating in
//        NMLoadingAnimation(isAnimating: isAnimating)
//    }
//}
//
//struct StatefulPreviewWrapper<Value, Content: View>: View {
//    @State private var value: Value
//    var content: (Binding<Value>) -> Content
//    
//    init(_ value: Value, content: @escaping (Binding<Value>) -> Content) {
//        self._value = State(initialValue: value)
//        self.content = content
//    }
//    
//    var body: some View { content($value) }
//}
