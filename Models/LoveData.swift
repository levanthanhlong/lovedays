import Foundation
import SwiftUI

enum NoteColor: String, Codable, CaseIterable {
    case cream, pink, yellow, green, mint, blue, purple

    var background: Color {
        switch self {
        case .cream:  return Color(red: 1.00, green: 0.98, blue: 0.95)
        case .pink:   return Color(red: 1.00, green: 0.88, blue: 0.91)
        case .yellow: return Color(red: 1.00, green: 0.97, blue: 0.80)
        case .green:  return Color(red: 0.88, green: 0.97, blue: 0.88)
        case .mint:   return Color(red: 0.84, green: 0.97, blue: 0.94)
        case .blue:   return Color(red: 0.86, green: 0.93, blue: 1.00)
        case .purple: return Color(red: 0.93, green: 0.88, blue: 1.00)
        }
    }

    var accent: Color {
        switch self {
        case .cream:  return Color(red: 0.84, green: 0.33, blue: 0.50)
        case .pink:   return Color(red: 0.84, green: 0.25, blue: 0.45)
        case .yellow: return Color(red: 0.65, green: 0.50, blue: 0.00)
        case .green:  return Color(red: 0.18, green: 0.58, blue: 0.28)
        case .mint:   return Color(red: 0.08, green: 0.55, blue: 0.48)
        case .blue:   return Color(red: 0.18, green: 0.38, blue: 0.78)
        case .purple: return Color(red: 0.48, green: 0.18, blue: 0.78)
        }
    }

    var dot: Color {
        switch self {
        case .cream:  return Color(red: 0.95, green: 0.88, blue: 0.82)
        case .pink:   return Color(red: 1.00, green: 0.72, blue: 0.80)
        case .yellow: return Color(red: 1.00, green: 0.90, blue: 0.50)
        case .green:  return Color(red: 0.65, green: 0.92, blue: 0.65)
        case .mint:   return Color(red: 0.60, green: 0.94, blue: 0.88)
        case .blue:   return Color(red: 0.65, green: 0.82, blue: 1.00)
        case .purple: return Color(red: 0.82, green: 0.72, blue: 1.00)
        }
    }
}

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
    var color: NoteColor
    let createdAt: Date
    var updatedAt: Date

    init(id: UUID = UUID(), title: String, content: String, color: NoteColor = .cream) {
        self.id = id
        self.title = title
        self.content = content
        self.color = color
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

enum NotificationOffset: String, Codable, CaseIterable {
    case onDay, dayBefore, threeDaysBefore, weekBefore

    var displayName: String {
        switch self {
        case .onDay:           return "Vào ngày diễn ra"
        case .dayBefore:       return "Trước 1 ngày"
        case .threeDaysBefore: return "Trước 3 ngày"
        case .weekBefore:      return "Trước 1 tuần"
        }
    }

    var daysOffset: Int {
        switch self {
        case .onDay:           return 0
        case .dayBefore:       return 1
        case .threeDaysBefore: return 3
        case .weekBefore:      return 7
        }
    }
}

struct CustomEvent: Identifiable, Codable {
    let id: UUID
    var title: String
    var date: Date
    var icon: String
    var notificationEnabled: Bool
    var notificationOffset: NotificationOffset
    var notificationHour: Int
    var notificationMinute: Int

    init(id: UUID = UUID(), title: String, date: Date, icon: String = "🌟",
         notificationEnabled: Bool = false,
         notificationOffset: NotificationOffset = .onDay,
         notificationHour: Int = 8, notificationMinute: Int = 0) {
        self.id = id
        self.title = title
        self.date = date
        self.icon = icon
        self.notificationEnabled = notificationEnabled
        self.notificationOffset = notificationOffset
        self.notificationHour = notificationHour
        self.notificationMinute = notificationMinute
    }
}
