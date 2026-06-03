import UserNotifications
import Foundation

final class NotificationManager: NSObject {
    static let shared = NotificationManager()
    private override init() { super.init() }

    func requestPermission() async -> Bool {
        (try? await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .badge, .sound])) ?? false
    }

    func authorizationStatus() async -> UNAuthorizationStatus {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }

    // MARK: - Schedule all reminders
    func scheduleAllReminders(startDate: Date, partnerName: String,
                              myBirthday: Date?, partnerBirthday: Date?,
                              myName: String) {
        let center = UNUserNotificationCenter.current()
        // Remove all managed identifiers
        center.removePendingNotificationRequests(withIdentifiers: allManagedIDs)

        scheduleMonthly(startDate: startDate, name: partnerName)
        scheduleYearlyCountdown(startDate: startDate, name: partnerName)

        if let bd = myBirthday {
            scheduleBirthdayCountdown(birthday: bd,
                                      name: myName.isEmpty ? "bạn" : myName,
                                      prefix: "bday_me")
        }
        if let bd = partnerBirthday {
            scheduleBirthdayCountdown(birthday: bd,
                                      name: partnerName.isEmpty ? "người ấy" : partnerName,
                                      prefix: "bday_partner")
        }
    }

    func scheduleCustomEventNotification(_ event: CustomEvent) {
        removeCustomEventNotification(event.id)
        guard event.notificationEnabled else { return }

        let calendar = Calendar.current
        guard let notifDate = calendar.date(
            byAdding: .day, value: -event.notificationOffset.daysOffset, to: event.date
        ) else { return }

        var comps = calendar.dateComponents([.year, .month, .day], from: notifDate)
        comps.hour = event.notificationHour; comps.minute = event.notificationMinute
        guard let dt = calendar.date(from: comps), dt > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "\(event.icon) \(event.title)"
        content.body  = notifBody(event)
        content.sound = .default

        add(UNNotificationRequest(identifier: "custom_event_\(event.id.uuidString)",
                                  content: content,
                                  trigger: UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)))
    }

    func removeCustomEventNotification(_ id: UUID) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["custom_event_\(id.uuidString)"])
    }

    func sendTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "💕 Test thông báo"
        content.body  = "Thông báo hoạt động! Thoát app rồi chờ 5 giây."
        content.sound = .default
        add(UNNotificationRequest(identifier: "test_notif", content: content,
                                  trigger: UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)))
    }

    // MARK: - Private helpers
    private var allManagedIDs: [String] {
        var ids = ["love_monthly", "love_yearly"]
        for d in 1...3 {
            ids += ["love_yearly_\(d)", "bday_me_\(d)", "bday_partner_\(d)"]
        }
        return ids
    }

    private func scheduleMonthly(startDate: Date, name: String) {
        let content = UNMutableNotificationContent()
        content.title = "💕 Kỷ niệm tháng này!"
        content.body  = "Hôm nay là kỷ niệm tháng với \(name.isEmpty ? "người ấy" : name)! ❤️"
        content.sound = .default
        var comps = DateComponents()
        comps.day = Calendar.current.component(.day, from: startDate)
        comps.hour = 20; comps.minute = 0
        add(UNNotificationRequest(identifier: "love_monthly", content: content,
                                  trigger: UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)))
    }

    // Yearly anniversary: on the day + 3 days countdown at 20:00
    private func scheduleYearlyCountdown(startDate: Date, name: String) {
        let cal = Calendar.current
        let label = name.isEmpty ? "người ấy" : name

        // On the day
        var onDay = cal.dateComponents([.month, .day], from: startDate)
        onDay.hour = 20; onDay.minute = 0
        let onContent = UNMutableNotificationContent()
        onContent.title = "🎉 Kỷ niệm yêu nhau!"
        onContent.body  = "Chúc mừng kỷ niệm với \(label)! Thật tuyệt vời 🥰"
        onContent.sound = .default
        add(UNNotificationRequest(identifier: "love_yearly", content: onContent,
                                  trigger: UNCalendarNotificationTrigger(dateMatching: onDay, repeats: true)))

        // 1, 2, 3 days before
        let messages = [
            1: "Ngày mai là kỷ niệm yêu với \(label)! 🎊 Chuẩn bị nhé!",
            2: "Còn 2 ngày nữa là kỷ niệm với \(label)! 💕",
            3: "Còn 3 ngày nữa là kỷ niệm với \(label)! 🌹"
        ]
        for (days, body) in messages {
            guard let d = cal.date(byAdding: .day, value: -days, to: startDate) else { continue }
            var comps = cal.dateComponents([.month, .day], from: d)
            comps.hour = 20; comps.minute = 0
            let c = UNMutableNotificationContent()
            c.title = "💕 Sắp đến kỷ niệm rồi!"; c.body = body; c.sound = .default
            add(UNNotificationRequest(identifier: "love_yearly_\(days)", content: c,
                                      trigger: UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)))
        }
    }

    // Birthday: on the day + 3 days countdown at 20:00
    private func scheduleBirthdayCountdown(birthday: Date, name: String, prefix: String) {
        let cal = Calendar.current

        // On the day
        var onDay = cal.dateComponents([.month, .day], from: birthday)
        onDay.hour = 20; onDay.minute = 0
        let onContent = UNMutableNotificationContent()
        onContent.title = "🎂 Sinh nhật \(name)!"
        onContent.body  = "Hôm nay là sinh nhật \(name)! Chúc mừng sinh nhật! 🎉"
        onContent.sound = .default
        add(UNNotificationRequest(identifier: "\(prefix)_0", content: onContent,
                                  trigger: UNCalendarNotificationTrigger(dateMatching: onDay, repeats: true)))

        // 1, 2, 3 days before
        let messages = [
            1: "Ngày mai là sinh nhật \(name)! 🎁 Đừng quên nhé!",
            2: "Còn 2 ngày nữa là sinh nhật \(name)! 🎂",
            3: "Còn 3 ngày nữa là sinh nhật \(name)! 🌸"
        ]
        for (days, body) in messages {
            guard let d = cal.date(byAdding: .day, value: -days, to: birthday) else { continue }
            var comps = cal.dateComponents([.month, .day], from: d)
            comps.hour = 20; comps.minute = 0
            let c = UNMutableNotificationContent()
            c.title = "🎂 Sắp đến sinh nhật \(name)!"; c.body = body; c.sound = .default
            add(UNNotificationRequest(identifier: "\(prefix)_\(days)", content: c,
                                      trigger: UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)))
        }
    }

    private func notifBody(_ event: CustomEvent) -> String {
        switch event.notificationOffset {
        case .onDay:           return "Hôm nay là ngày \(event.title)! 🎉"
        case .dayBefore:       return "Ngày mai là ngày \(event.title)!"
        case .threeDaysBefore: return "\(event.title) sẽ diễn ra sau 3 ngày nữa!"
        case .weekBefore:      return "\(event.title) sẽ diễn ra sau 1 tuần nữa!"
        }
    }

    private func add(_ request: UNNotificationRequest) {
        UNUserNotificationCenter.current().add(request) { error in
            if let error { print("[Notif] \(error)") }
        }
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler handler: @escaping (UNNotificationPresentationOptions) -> Void) {
        handler([.banner, .sound, .badge])
    }
}
