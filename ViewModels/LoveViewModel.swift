import SwiftUI
import Combine
import WidgetKit

private enum UDKey {
    static let startDate           = "ld_start_date"
    static let partnerName         = "ld_partner_name"
    static let myName              = "ld_my_name"
    static let hasCompletedOnboard = "ld_onboarded"
    static let myBirthday          = "ld_my_birthday"
    static let partnerBirthday     = "ld_partner_birthday"
    static let customEvents        = "ld_custom_events"
    static let notes               = "ld_notes"
}

private let sharedPhotoURL: URL? =
    FileManager.default
        .containerURL(forSecurityApplicationGroupIdentifier: "group.com.app.testcmc")?
        .appendingPathComponent("couple_photo.jpg")

private let couplePhotoURL: URL = {
    FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("couple_photo.jpg")
}()

private let myPhotoURL: URL = {
    FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("my_photo.jpg")
}()

private let partnerPhotoURL: URL = {
    FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("partner_photo.jpg")
}()

@MainActor
final class LoveViewModel: ObservableObject {
    // MARK: - Published
    @Published private(set) var startDate: Date
    @Published private(set) var partnerName: String
    @Published private(set) var myName: String
    @Published private(set) var couplePhotoData: Data?
    @Published private(set) var myPhotoData: Data?
    @Published private(set) var partnerPhotoData: Data?
    @Published private(set) var hasCompletedOnboarding: Bool
    @Published private(set) var diff: DateDifference = .zero
    @Published private(set) var nextMonthly: Anniversary?
    @Published private(set) var nextYearly: Anniversary?
    @Published private(set) var myBirthday: Date?
    @Published private(set) var partnerBirthday: Date?
    @Published private(set) var nextMyBirthday: Anniversary?
    @Published private(set) var nextPartnerBirthday: Anniversary?
    @Published private(set) var customEvents: [CustomEvent] = []
    @Published private(set) var notes: [Note] = []
    @Published var heartAnimating = false

    // MARK: - Private
    private let defaults = UserDefaults.standard
    private let sharedDefaults = UserDefaults(suiteName: "group.com.app.testcmc")
    private var timer: Timer?

    // MARK: - Init
    init() {
        startDate              = (defaults.object(forKey: UDKey.startDate) as? Date) ?? Date()
        partnerName            = defaults.string(forKey: UDKey.partnerName) ?? ""
        myName                 = defaults.string(forKey: UDKey.myName) ?? ""
        couplePhotoData        = try? Data(contentsOf: couplePhotoURL)
        myPhotoData            = try? Data(contentsOf: myPhotoURL)
        partnerPhotoData       = try? Data(contentsOf: partnerPhotoURL)
        hasCompletedOnboarding = defaults.bool(forKey: UDKey.hasCompletedOnboard)
        myBirthday             = defaults.object(forKey: UDKey.myBirthday) as? Date
        partnerBirthday        = defaults.object(forKey: UDKey.partnerBirthday) as? Date
        if let data = defaults.data(forKey: UDKey.customEvents),
           let decoded = try? JSONDecoder().decode([CustomEvent].self, from: data) {
            customEvents = decoded
        }
        if let data = defaults.data(forKey: UDKey.notes),
           let decoded = try? JSONDecoder().decode([Note].self, from: data) {
            notes = decoded
        }
        recalculate()
        startTimer()
    }

    deinit { timer?.invalidate() }

    // MARK: - Save relationship info
    func saveStartDate(_ date: Date) {
        startDate = date
        defaults.set(date, forKey: UDKey.startDate)
        sharedDefaults?.set(date, forKey: UDKey.startDate)
        recalculate()
        scheduleNotifications()
        WidgetCenter.shared.reloadAllTimelines()
        HapticManager.notification(.success)
    }

    func saveMyName(_ name: String) {
        myName = name
        defaults.set(name, forKey: UDKey.myName)
        recalculate()
    }

    func savePartnerName(_ name: String) {
        partnerName = name
        defaults.set(name, forKey: UDKey.partnerName)
        recalculate()
        scheduleNotifications()
    }

    func saveCouplePhoto(_ data: Data?) {
        couplePhotoData = data
        if let data {
            try? data.write(to: couplePhotoURL, options: .atomic)
            if let url = sharedPhotoURL { try? data.write(to: url, options: .atomic) }
        } else {
            try? FileManager.default.removeItem(at: couplePhotoURL)
        try? FileManager.default.removeItem(at: myPhotoURL)
        try? FileManager.default.removeItem(at: partnerPhotoURL)
            if let url = sharedPhotoURL { try? FileManager.default.removeItem(at: url) }
        }

        WidgetCenter.shared.reloadAllTimelines()
        HapticManager.impact(.light)
    }

    func saveMyPhoto(_ data: Data?) {
        myPhotoData = data
        if let data { try? data.write(to: myPhotoURL, options: .atomic) }
        else        { try? FileManager.default.removeItem(at: myPhotoURL) }
        HapticManager.impact(.light)
    }

    func savePartnerPhoto(_ data: Data?) {
        partnerPhotoData = data
        if let data { try? data.write(to: partnerPhotoURL, options: .atomic) }
        else        { try? FileManager.default.removeItem(at: partnerPhotoURL) }
        HapticManager.impact(.light)
    }

    // MARK: - Notes
    func addNote(_ note: Note) {
        notes.insert(note, at: 0)
        persistNotes()
        HapticManager.notification(.success)
    }

    func updateNote(_ note: Note) {
        guard let idx = notes.firstIndex(where: { $0.id == note.id }) else { return }
        notes[idx] = note
        persistNotes()
    }

    func deleteNote(id: UUID) {
        notes.removeAll { $0.id == id }
        persistNotes()
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        defaults.set(true, forKey: UDKey.hasCompletedOnboard)
        HapticManager.notification(.success)
    }

    // MARK: - Birthdays
    func saveMyBirthday(_ date: Date?) {
        myBirthday = date
        if let date { defaults.set(date, forKey: UDKey.myBirthday) }
        else        { defaults.removeObject(forKey: UDKey.myBirthday) }
        recalculate()
        scheduleNotifications()
    }

    func savePartnerBirthday(_ date: Date?) {
        partnerBirthday = date
        if let date { defaults.set(date, forKey: UDKey.partnerBirthday) }
        else        { defaults.removeObject(forKey: UDKey.partnerBirthday) }
        recalculate()
        scheduleNotifications()
    }

    // MARK: - Custom events
    func addCustomEvent(_ event: CustomEvent) {
        customEvents.append(event)
        persistCustomEvents()
        scheduleEventNotif(event)
        HapticManager.notification(.success)
    }

    func updateCustomEvent(_ event: CustomEvent) {
        guard let idx = customEvents.firstIndex(where: { $0.id == event.id }) else { return }
        customEvents[idx] = event
        persistCustomEvents()
        scheduleEventNotif(event)
        HapticManager.notification(.success)
    }

    func deleteCustomEvent(id: UUID) {
        customEvents.removeAll { $0.id == id }
        persistCustomEvents()
        NotificationManager.shared.removeCustomEventNotification(id)
    }

    private func scheduleEventNotif(_ event: CustomEvent) {
        guard event.notificationEnabled else { return }
        Task {
            // Request permission if not yet determined, then schedule
            let status = await NotificationManager.shared.authorizationStatus()
            if status == .notDetermined {
                _ = await NotificationManager.shared.requestPermission()
            }
            NotificationManager.shared.scheduleCustomEventNotification(event)
        }
    }

    // MARK: - Computed
    var couplePhoto: UIImage? { couplePhotoData.flatMap { UIImage(data: $0) } }
    var myPhoto: UIImage? { myPhotoData.flatMap { UIImage(data: $0) } }
    var partnerPhoto: UIImage? { partnerPhotoData.flatMap { UIImage(data: $0) } }

    var displayTitle: String {
        switch (myName.isEmpty, partnerName.isEmpty) {
        case (false, false): return "\(myName) & \(partnerName)"
        case (true,  false): return "Bạn & \(partnerName)"
        default:             return "Love Days 💕"
        }
    }

    var formattedStartDate: String {
        DateCalculator.formattedDate(startDate)
    }

    // MARK: - Heart animation
    func triggerHeart() {
        heartAnimating = true
        HapticManager.heartbeat()
        Task {
            try? await Task.sleep(nanoseconds: 600_000_000)
            heartAnimating = false
        }
    }

    // MARK: - Reset
    func performReset() {
        let keys: [String] = [
            UDKey.startDate, UDKey.partnerName, UDKey.myName,
            UDKey.hasCompletedOnboard,
            UDKey.myBirthday, UDKey.partnerBirthday, UDKey.customEvents
        ]
        keys.forEach { defaults.removeObject(forKey: $0) }
        try? FileManager.default.removeItem(at: couplePhotoURL)
        try? FileManager.default.removeItem(at: myPhotoURL)
        try? FileManager.default.removeItem(at: partnerPhotoURL)
        startDate              = Date()
        partnerName            = ""
        myName                 = ""
        couplePhotoData        = nil
        myPhotoData            = nil
        partnerPhotoData       = nil
        hasCompletedOnboarding = false
        myBirthday             = nil
        partnerBirthday        = nil
        customEvents           = []
        notes                  = []
        recalculate()
        HapticManager.notification(.warning)
    }

    // MARK: - Private helpers
    private func recalculate() {
        diff        = DateCalculator.difference(from: startDate)
        nextMonthly = DateCalculator.nextMonthlyAnniversary(from: startDate)
        nextYearly  = DateCalculator.nextYearlyAnniversary(from: startDate)

        let nameMe      = myName.isEmpty      ? "Bạn"      : myName
        let namePartner = partnerName.isEmpty ? "Người ấy" : partnerName
        nextMyBirthday      = myBirthday.map      { DateCalculator.nextBirthday(name: nameMe,      birthday: $0) }
        nextPartnerBirthday = partnerBirthday.map { DateCalculator.nextBirthday(name: namePartner, birthday: $0) }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in self?.recalculate() }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    private func scheduleNotifications() {
        Task {
            guard await NotificationManager.shared.authorizationStatus() == .authorized else { return }
            NotificationManager.shared.scheduleAllReminders(
                startDate: startDate, partnerName: partnerName,
                myBirthday: myBirthday, partnerBirthday: partnerBirthday,
                myName: myName)
        }
    }

    private func persistCustomEvents() {
        if let data = try? JSONEncoder().encode(customEvents) {
            defaults.set(data, forKey: UDKey.customEvents)
        }
    }

    private func persistNotes() {
        if let data = try? JSONEncoder().encode(notes) {
            defaults.set(data, forKey: UDKey.notes)
        }
    }
}

extension DateDifference {
    static var zero: DateDifference {
        DateDifference(totalDays: 0, years: 0, months: 0, days: 0, hours: 0, minutes: 0, seconds: 0)
    }
}
