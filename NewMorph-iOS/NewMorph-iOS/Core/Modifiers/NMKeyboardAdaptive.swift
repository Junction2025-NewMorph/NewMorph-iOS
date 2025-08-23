//
//  NMKeyboardAdaptive.swift
//  NewMorph-iOS
//
//  Created by mini on 8/22/25.
//

import Combine
import SwiftUI

/// 키보드가 나타날 때/사라질 때, 화면을 자동으로 위로 올려주는 ViewModifier
/// - SwiftUI에서 TextField, TextEditor 같은 입력 컴포넌트가 키보드에 가려지는 것을 방지.
/// - Combine의 NotificationCenter publisher를 활용.
struct NMKeyboardAdaptive: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0
    
    private let keyboardWillShow = NotificationCenter.default
        .publisher(for: UIResponder.keyboardWillShowNotification)
        .compactMap { notification in
            notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        }
        .map { rect in
            rect.height
        }
    
    private let keyboardWillHide = NotificationCenter.default
        .publisher(for: UIResponder.keyboardWillHideNotification)
        .map { _ in CGFloat(0) }
    
    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight)
            .onReceive(
                Publishers.Merge(keyboardWillShow, keyboardWillHide)
            ) { height in
                withAnimation {
                    self.keyboardHeight = height
                }
            }
    }
}

extension View {
    /// 뷰에 `.NMKeyboardAdaptive()`를 붙이면 자동으로 키보드 높이에 따라
    /// 하단 패딩이 조정됨.
    ///
    /// 예:
    /// ```swift
    /// VStack {
    ///     TextField("입력", text: $text)
    /// }
    /// .NMKeyboardAdaptive()
    /// ```
    func nmKeyboardAdaptive() -> some View {
        ModifiedContent(content: self, modifier: NMKeyboardAdaptive())
    }
}
