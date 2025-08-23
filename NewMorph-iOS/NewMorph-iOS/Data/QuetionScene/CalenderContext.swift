//
//  CalenderContext.swift
//  NewMorph-iOS
//
//  Created by mini on 8/23/25.
//

import SwiftData
import SwiftUI

struct MonthContext: Equatable {
    var year: Int
    var month: Int   
    
    var displayTitle: String {
        String(format: "%02d월", month)
    }
    
    func clampedDay(_ day: Int, in calendar: Calendar = .current) -> Int {
        let range = calendar.range(of: .day, in: .month, for: firstDateOfMonth(calendar))!
        return min(max(day, range.lowerBound), range.upperBound - 1) // lowerBound is 1
    }
    
    func firstDateOfMonth(_ calendar: Calendar = .current) -> Date {
        let comps = DateComponents(year: year, month: month, day: 1)
        return calendar.date(from: comps)!
    }
    
    func date(day: Int, calendar: Calendar = .current) -> Date {
        let d = clampedDay(day, in: calendar)
        let comps = DateComponents(year: year, month: month, day: d)
        return calendar.date(from: comps)!
    }
    
    func dayBounds(calendar: Calendar = .current) -> ClosedRange<Date> {
        let first = firstDateOfMonth(calendar)
        var comps = DateComponents()
        comps.month = 1
        comps.day = -1
        let last = calendar.date(byAdding: comps, to: first)!
        return first...last
    }
}
