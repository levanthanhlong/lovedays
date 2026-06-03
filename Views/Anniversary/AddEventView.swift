import SwiftUI

struct AddEventView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: LoveViewModel
    var event: CustomEvent? // nil = tạo mới

    @State private var title = ""
    @State private var date = Date()
    @State private var selectedIcon = "🌟"
    @State private var notifEnabled = false
    @State private var notifOffset: NotificationOffset = .onDay
    @State private var notifTime: Date = Calendar.current.date(from: DateComponents(hour: 8, minute: 0)) ?? Date()

    private let icons = [
        "🌟","💍","🎂","🎉","🏖️","✈️",
        "🎓","🎁","💑","🏠","🎵","🌸",
        "🍕","🎬","🏃","💪","🎮","📚",
        "🌺","🦋","🌈","🎪","🎠","🌙"
    ]
    private let columns = Array(repeating: GridItem(.flexible()), count: 6)
    private var isEditing: Bool { event != nil }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.mainGradient.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        Text(selectedIcon).font(.system(size: 64)).padding(.top, 8)
                        iconPickerSection
                        titleSection
                        dateSection
                        notificationSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle(isEditing ? "Chỉnh sửa sự kiện" : "Tạo sự kiện")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Hủy") { dismiss() }.foregroundStyle(.secondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Lưu") { save(); dismiss() }
                        .font(AppTheme.bodyFont())
                        .foregroundStyle(title.isEmpty ? .secondary : AppTheme.deepRose)
                        .disabled(title.isEmpty)
                }
            }
        }
        .onAppear {
            if let e = event {
                title = e.title; date = e.date; selectedIcon = e.icon
                notifEnabled = e.notificationEnabled; notifOffset = e.notificationOffset
                let cal = Calendar.current
                notifTime = cal.date(from: DateComponents(hour: e.notificationHour, minute: e.notificationMinute)) ?? notifTime
            }
        }
    }

    // MARK: - Icon Picker
    private var iconPickerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Biểu tượng").font(AppTheme.headlineFont()).foregroundStyle(AppTheme.deepRose)
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(icons, id: \.self) { icon in
                    Button {
                        HapticManager.selection(); selectedIcon = icon
                    } label: {
                        Text(icon).font(.system(size: 28))
                            .frame(maxWidth: .infinity).padding(.vertical, 8)
                            .background(RoundedRectangle(cornerRadius: 10)
                                .fill(selectedIcon == icon ? AppTheme.deepRose.opacity(0.15) : Color.clear))
                            .overlay(RoundedRectangle(cornerRadius: 10)
                                .stroke(selectedIcon == icon ? AppTheme.deepRose : Color.clear, lineWidth: 1.5))
                    }
                }
            }
        }
        .cardStyle()
    }

    // MARK: - Title
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tên sự kiện").font(AppTheme.headlineFont()).foregroundStyle(AppTheme.deepRose)
            TextField("VD: Lần đầu gặp nhau...", text: $title)
                .font(AppTheme.bodyFont()).padding(14)
                .background(RoundedRectangle(cornerRadius: 12).fill(AppTheme.softPink.opacity(0.5)))
        }
        .cardStyle()
    }

    // MARK: - Date
    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ngày diễn ra").font(AppTheme.headlineFont()).foregroundStyle(AppTheme.deepRose)
            DatePicker("", selection: $date, displayedComponents: .date)
                .datePickerStyle(.graphical).tint(AppTheme.deepRose)
        }
        .cardStyle()
    }

    // MARK: - Notification
    private var notificationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("🔔 Thông báo").font(AppTheme.headlineFont()).foregroundStyle(AppTheme.deepRose)
                    Text("Nhắc nhở trước sự kiện").font(AppTheme.captionFont()).foregroundStyle(.secondary)
                }
                Spacer()
                Toggle("", isOn: $notifEnabled).tint(AppTheme.deepRose)
            }

            if notifEnabled {
                Divider()

                // Offset picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Nhắc trước").font(AppTheme.bodyFont()).foregroundStyle(.primary)
                    VStack(spacing: 0) {
                        ForEach(NotificationOffset.allCases, id: \.self) { offset in
                            Button {
                                HapticManager.selection(); notifOffset = offset
                            } label: {
                                HStack {
                                    Text(offset.displayName).font(AppTheme.bodyFont()).foregroundStyle(.primary)
                                    Spacer()
                                    if notifOffset == offset {
                                        Image(systemName: "checkmark").foregroundStyle(AppTheme.deepRose).fontWeight(.semibold)
                                    }
                                }
                                .padding(.horizontal, 14).padding(.vertical, 12)
                            }
                            if offset != NotificationOffset.allCases.last { Divider().padding(.horizontal, 14) }
                        }
                    }
                    .background(RoundedRectangle(cornerRadius: 12).fill(AppTheme.softPink.opacity(0.4)))
                }

                // Time picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Vào lúc").font(AppTheme.bodyFont()).foregroundStyle(.primary)
                    DatePicker("", selection: $notifTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel).tint(AppTheme.deepRose).frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 12).fill(AppTheme.softPink.opacity(0.4)))
                        .labelsHidden()
                }
            }
        }
        .cardStyle()
    }

    // MARK: - Save
    private func save() {
        let cal = Calendar.current
        let h = cal.component(.hour, from: notifTime)
        let m = cal.component(.minute, from: notifTime)

        if var existing = event {
            existing.title = title; existing.date = date; existing.icon = selectedIcon
            existing.notificationEnabled = notifEnabled; existing.notificationOffset = notifOffset
            existing.notificationHour = h; existing.notificationMinute = m
            viewModel.updateCustomEvent(existing)
        } else {
            viewModel.addCustomEvent(CustomEvent(
                title: title, date: date, icon: selectedIcon,
                notificationEnabled: notifEnabled, notificationOffset: notifOffset,
                notificationHour: h, notificationMinute: m
            ))
        }
    }
}
