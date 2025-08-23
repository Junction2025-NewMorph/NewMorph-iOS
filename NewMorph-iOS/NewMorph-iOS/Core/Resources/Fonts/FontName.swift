//
//  FontName.swift
//  NewMorph-iOS
//
//  Created by mini on 8/21/25.
//

import SwiftUI
import UIKit

enum FontName: String {
    case pretendardBlack = "Pretendard-Black"
    case pretendardBold = "Pretendard-Bold"
    case pretendardExtraBold = "Pretendard-ExtraBold"
    case pretendardExtraLight = "Pretendard-ExtraLight"
    case pretendardLight = "Pretendard-Light"
    case pretendardMedium = "Pretendard-Medium"
    case pretendardRegular = "Pretendard-Regular"
    case pretendardSemiBold = "Pretendard-SemiBold"
    case pretendardThin = "Pretendard-Thin"
    case jejudoldam = "EF_jejudoldam"
}

extension Font {
    // static let titleBold24: Font = .custom(FontName.pretendardBold.rawValue, size: 24)
}

extension UIFont {
    // static let titleBold24: UIFont = UIFont(name: FontName.pretendardBold.rawValue, size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .bold)
}
