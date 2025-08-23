//
//  String+asHighlight.swift
//  NewMorph-iOS
//
//  Created by mini on 8/22/25.
//

import SwiftUI

extension String {
    /// 특정 String, Color만 색상을 주는 메서드
    func asHighlight(
        highlightedString: String,
        highlightColor: Color
    ) -> AttributedString {
        var attributed = AttributedString(self)
        if let range = attributed.range(of: highlightedString) {
            attributed[range].foregroundColor = highlightColor
        }
        
        return attributed
    }
}
