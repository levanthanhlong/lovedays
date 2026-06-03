import UserNotifications
import Foundation

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    func requestPermission() async -> Bool {
        (try? await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .badge, .sound])) ?? false
    }

    func scheduleAnniversaryReminders(startDate: Date, partnerName: String) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        scheduleMonthly(startDate: startDate, name: partnerName)
        scheduleYearly(startDate: startDate, name: partnerName)
    }

    func authorizationStatus() async -> UNAuthorizationStatus {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }

    // MARK: - Private
    private func scheduleMonthly(startDate: Date, name: String) {
        let partnerLabel = name.isEmpty ? "người ấy" : name
        let content = UNMutableNotificationContent()
        content.title = "💕 Kỷ niệm tháng này!"
        content.body  = "Hôm nay là ngày kỷ niệm tháng với \(partnerLabel). Đừng quên nhé! ❤️"
        content.sound = .default

        var comps = DateComponents()
        comps.day    = Calendar.current.component(.day, from: startDate)
        comps.hour   = 8
        comps.minute = 0

        let request = UNNotificationRequest(
            identifier: "love_monthly",
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        )
        UNUserNotificationCenter.current().add(request)
    }

    private func scheduleYearly(startDate: Date, name: String) {
        let partnerLabel = name.isEmpty ? "người ấy" : name
        let content = UNMutableNotificationContent()
        content.title = "🎉 Kỷ niệm yêu nhau!"
        content.body  = "Chúc mừng kỷ niệm với \(partnerLabel)! Thật tuyệt vời! 🥰"
        content.sound = .default

        let cal = Calendar.current
        var comps = DateComponents()
        comps.month  = cal.component(.month, from: startDate)
        comps.day    = cal.component(.day,   from: startDate)
        comps.hour   = 8
        comps.minute = 0

        let request = UNNotificationRequest(
            identifier: "love_yearly",
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        )
        UNUserNotificationCenter.current().add(request)
    }
}
