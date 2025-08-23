import SwiftUI
import SwiftData

@Model
final class JournalEntry {
    @Attribute(.unique) var id: String
    var date: Date
    var prompt: String
    var answer: String
    
    init(date: Date, prompt: String, answer: String) {
        self.date = date
        self.prompt = prompt
        self.answer = answer
        self.id = Self.makeId(for: date)
    }
    
    static func makeId(for date: Date) -> String {
        let y = Calendar.current.component(.year, from: date)
        let m = Calendar.current.component(.month, from: date)
        let d = Calendar.current.component(.day, from: date)
        return String(format: "%04d-%02d-%02d", y, m, d)
    }
}
