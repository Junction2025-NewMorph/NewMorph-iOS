//
//  View+triggerHapticFeedback.swift
//  NewMorph-iOS
//
//  Created by mini on 8/24/25.
//

import SwiftUI

extension View {
    /// 햅틱 발생시키는 UIKit Extension Method
    func triggerHapticFeedback() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}
