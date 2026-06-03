import Foundation

enum DateCalculator {
    static func difference(from start: Date, to end: Date = Date()) -> DateDifference {
        let calendar = Calendar.current
        let comps = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second],
                                            from: start, to: end)
        let totalDays = calendar.dateComponents([.day], from: start, to: end).day ?? 0
        return DateDifference(
            totalDays: max(0, totalDays),
            years:   max(0, comps.year   ?? 0),
            months:  max(0, comps.month  ?? 0),
            days:    max(0, comps.day    ?? 0),
            hours:   max(0, comps.hour   ?? 0),
            minutes: max(0, comps.minute ?? 0),
            seconds: max(0, comps.second ?? 0)
        )
    }

    static func nextMonthlyAnniversary(from startDate: Date) -> Anniversary {
        let calendar = Calendar.current
        let now = Date()
        let dayOfStart = calendar.component(.day, from: startDate)

        var comps = calendar.dateComponents([.year, .month], from: now)
        comps.day = dayOfStart

        guard var next = calendar.date(from: comps) else {
            return Anniversary(title: "Kỷ niệm tháng", date: now, daysUntil: 0, isMonthly: true)
        }
        // Only advance if anniversary has already passed today (not if it IS today)
        if calendar.startOfDay(for: next) < calendar.startOfDay(for: now) {
            comps.month = (comps.month ?? 1) + 1
            next = calendar.date(from: comps) ?? next
        }

        let daysUntil = max(0, calendar.dateComponents([.day], from: calendar.startOfDay(for: now),
                                                        to: calendar.startOfDay(for: next)).day ?? 0)
        let diff = difference(from: startDate, to: next)
        let totalMonths = diff.years * 12 + diff.months

        return Anniversary(title: "Kỷ niệm \(totalMonths) tháng",
                           date: next, daysUntil: daysUntil, isMonthly: true)
    }

    static func nextYearlyAnniversary(from startDate: Date) -> Anniversary {
        let calendar = Calendar.current
        let now = Date()

        var comps = calendar.dateComponents([.month, .day], from: startDate)
        comps.year = calendar.component(.year, from: now)

        guard var next = calendar.date(from: comps) else {
            return Anniversary(title: "Kỷ niệm năm", date: now, daysUntil: 0, isMonthly: false)
        }
        // Only advance if anniversary has already passed today (not if it IS today)
        if calendar.startOfDay(for: next) < calendar.startOfDay(for: now) {
            comps.year = (comps.year ?? 2024) + 1
            next = calendar.date(from: comps) ?? next
        }

        let daysUntil = max(0, calendar.dateComponents([.day], from: calendar.startOfDay(for: now),
                                                        to: calendar.startOfDay(for: next)).day ?? 0)
        let years = calendar.dateComponents([.year], from: startDate, to: next).year ?? 1

        return Anniversary(title: "Kỷ niệm \(years) năm",
                           date: next, daysUntil: daysUntil, isMonthly: false)
    }

    static func nextBirthday(name: String, birthday: Date) -> Anniversary {
        let calendar = Calendar.current
        let now = Date()

        var comps = calendar.dateComponents([.month, .day], from: birthday)
        comps.year = calendar.component(.year, from: now)

        guard var next = calendar.date(from: comps) else {
            return Anniversary(title: "Sinh nhật \(name)", date: now, daysUntil: 0, isMonthly: false)
        }
        if calendar.startOfDay(for: next) < calendar.startOfDay(for: now) {
            comps.year = (comps.year ?? 2024) + 1
            next = calendar.date(from: comps) ?? next
        }

        let daysUntil = max(0, calendar.dateComponents([.day], from: calendar.startOfDay(for: now),
                                                        to: calendar.startOfDay(for: next)).day ?? 0)
        let age = calendar.dateComponents([.year], from: birthday, to: next).year ?? 0

        return Anniversary(title: "Sinh nhật \(name) (\(age) tuổi)",
                           date: next, daysUntil: daysUntil, isMonthly: false)
    }

    static func daysUntil(_ date: Date) -> Int {
        let calendar = Calendar.current
        let now = Date()
        return max(0, calendar.dateComponents([.day],
            from: calendar.startOfDay(for: now),
            to: calendar.startOfDay(for: date)).day ?? 0)
    }

    static func zodiacSign(for date: Date) -> (symbol: String, name: String) {
        let cal = Calendar.current
        let m = cal.component(.month, from: date)
        let d = cal.component(.day,   from: date)
        switch (m, d) {
        case (3, 21...), (4, ...19): return ("♈", "Bạch Dương")
        case (4, 20...), (5, ...20): return ("♉", "Kim Ngưu")
        case (5, 21...), (6, ...20): return ("♊", "Song Tử")
        case (6, 21...), (7, ...22): return ("♋", "Cự Giải")
        case (7, 23...), (8, ...22): return ("♌", "Sư Tử")
        case (8, 23...), (9, ...22): return ("♍", "Xử Nữ")
        case (9, 23...), (10,...22): return ("♎", "Thiên Bình")
        case (10,23...), (11,...21): return ("♏", "Bọ Cạp")
        case (11,22...), (12,...21): return ("♐", "Nhân Mã")
        case (12,22...), (1, ...19): return ("♑", "Ma Kết")
        case (1, 20...), (2, ...18): return ("♒", "Bảo Bình")
        default:                     return ("♓", "Song Ngư")
        }
    }

    static func formattedDate(_ date: Date, format: String = "dd/MM/yyyy") -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = format
        fmt.locale = Locale(identifier: "vi_VN")
        return fmt.string(from: date)
    }
}
