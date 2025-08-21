//
//  Item.swift
//  NewMorph-iOS
//
//  Created by mini on 8/21/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
