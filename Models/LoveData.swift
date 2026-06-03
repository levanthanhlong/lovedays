import Foundation

struct DateDifference {
    let totalDays: Int
    let years: Int
    let months: Int
    let days: Int
    let hours: Int
    let minutes: Int
    let seconds: Int
}

struct Anniversary {
    let title: String
    let date: Date
    let daysUntil: Int
    let isMonthly: Bool
}

struct Note: Identifiable, Codable {
    let id: UUID
    var title: String
    var content: String
    let createdAt: Date
    var updatedAt: Date

    init(id: UUID = UUID(), title: String, content: String) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

struct CustomEvent: Identifiable, Codable {
    let id: UUID
    var title: String
    var date: Date
    var icon: String

    init(id: UUID = UUID(), title: String, date: Date, icon: String = "🌟") {
        self.id = id
        self.title = title
        self.date = date
        self.icon = icon
    }
}
