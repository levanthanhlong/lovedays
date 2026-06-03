import SwiftUI
import PhotosUI

struct SettingsView: View {
    @ObservedObject var viewModel: LoveViewModel
    @State private var myName = ""
    @State private var partnerName = ""
    @State private var startDate = Date()
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showDatePicker = false
    @State private var showResetAlert = false
    @State private var notifAuthorized = false

    // Birthday
    @State private var myBirthday: Date = Calendar.current.date(from: DateComponents(year: 1995, month: 1, day: 1)) ?? Date()
    @State private var myBirthdaySet = false
    @State private var showMyBirthdayPicker = false
    @State private var partnerBirthday: Date = Calendar.current.date(from: DateComponents(year: 1995, month: 1, day: 1)) ?? Date()
    @State private var partnerBirthdaySet = false
    @State private var showPartnerBirthdayPicker = false

    var body: some View {
        ZStack {
            AppTheme.mainGradient.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    TabHeader(emoji: "⚙️", title: "Cài đặt", subtitle: "Tùy chỉnh thông tin của bạn")
                    themeSection
                    profileSection
                    relationshipSection
                    notificationRow
                    testNotifButton
                    resetButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            myName = viewModel.myName; partnerName = viewModel.partnerName
            startDate = viewModel.startDate
            if let bd = viewModel.myBirthday      { myBirthday = bd;      myBirthdaySet = true }
            if let bd = viewModel.partnerBirthday { partnerBirthday = bd; partnerBirthdaySet = true }
            checkNotifStatus()
        }
        .alert("Xóa tất cả dữ liệu?", isPresented: $showResetAlert) {
            Button("Xóa", role: .destructive) { resetAll() }
            Button("Hủy", role: .cancel) {}
        } message: {
            Text("Toàn bộ thông tin, ảnh và sự kiện sẽ bị xóa vĩnh viễn.")
        }
    }

    // MARK: - Theme
    private var themeSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(LinearGradient(
                            colors: [Color(red:0.55,green:0.35,blue:0.95), Color(red:0.8,green:0.3,blue:0.9)],
                            startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 32, height: 32)
                    Image(systemName: "swatchpalette.fill")
                        .font(.system(size: 15, weight: .medium)).foregroundStyle(.white)
                }
                Text("Chủ đề").font(AppTheme.headlineFont()).foregroundStyle(AppTheme.deepRose)
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                ForEach(AppThemeStyle.allCases, id: \.self) { style in
                    Button {
                        HapticManager.selection()
                        withAnimation(.easeInOut(duration: 0.25)) { ThemeManager.shared.style = style }
                    } label: {
                        VStack(spacing: 4) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(colors: [style.primary, style.secondary],
                                                        startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 40, height: 40)
                                    .shadow(color: style.primary.opacity(0.35), radius: 4, y: 2)
                                if ThemeManager.shared.style == style {
                                    Circle().stroke(.white, lineWidth: 2).frame(width: 40, height: 40)
                                    Image(systemName: "checkmark").font(.system(size: 12, weight: .bold)).foregroundStyle(.white)
                                }
                            }
                            Text(style.displayName).font(.system(size: 9, design: .rounded)).foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .card()
    }

    // MARK: - Profile (names + photo + birthday)
    private var profileSection: some View {
        VStack(spacing: 0) {
            // Couple photo banner
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                ZStack(alignment: .bottomTrailing) {
                    if let img = viewModel.couplePhoto {
                        Image(uiImage: img).resizable().scaledToFill()
                            .frame(height: 140).clipped()
                    } else {
                        Rectangle().fill(AppTheme.softPink.opacity(0.7)).frame(height: 140)
                            .overlay(VStack(spacing: 6) {
                                Image(systemName: "photo.badge.plus").font(.system(size: 32)).foregroundStyle(AppTheme.roseGold)
                                Text("Thêm ảnh đôi").font(AppTheme.captionFont()).foregroundStyle(AppTheme.roseGold)
                            })
                    }
                    HStack(spacing: 6) {
                        Image(systemName: "camera.fill").font(.system(size: 11))
                        Text("Đổi ảnh").font(.system(size: 11, weight: .medium, design: .rounded))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(Capsule().fill(.black.opacity(0.4)))
                    .padding(10)
                }
            }
            .onChange(of: selectedPhoto) { item in
                Task { if let d = try? await item?.loadTransferable(type: Data.self) { viewModel.saveCouplePhoto(d) } }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            if viewModel.couplePhoto != nil {
                Button { viewModel.saveCouplePhoto(nil) } label: {
                    HStack { Spacer(); Label("Xóa ảnh", systemImage: "trash").font(AppTheme.captionFont()).foregroundStyle(.red.opacity(0.8)); Spacer() }
                    .padding(.vertical, 8)
                }
            }

            Divider().padding(.vertical, 4)

            // Name fields
            settingRow(sfIcon: "person.fill", color: Color(red:0.3,green:0.6,blue:1.0), title: "Tên của bạn") {
                TextField("Nhập tên", text: $myName).font(AppTheme.bodyFont())
                    .multilineTextAlignment(.trailing).foregroundStyle(AppTheme.deepRose)
                    .onChange(of: myName) { viewModel.saveMyName($0) }
            }
            thinDivider()
            settingRow(sfIcon: "heart.fill", color: AppTheme.deepRose, title: "Tên người ấy") {
                TextField("Nhập tên", text: $partnerName).font(AppTheme.bodyFont())
                    .multilineTextAlignment(.trailing).foregroundStyle(AppTheme.deepRose)
                    .onChange(of: partnerName) { viewModel.savePartnerName($0) }
            }
            thinDivider()

            // Birthdays
            birthdayRow(title: "Sinh nhật của bạn", color: Color(red:1.0,green:0.55,blue:0.6),
                        date: $myBirthday, isSet: $myBirthdaySet, showPicker: $showMyBirthdayPicker) {
                viewModel.saveMyBirthday($0)
            }
            thinDivider()
            birthdayRow(title: "Sinh nhật người ấy", color: Color(red:0.7,green:0.4,blue:1.0),
                        date: $partnerBirthday, isSet: $partnerBirthdaySet, showPicker: $showPartnerBirthdayPicker) {
                viewModel.savePartnerBirthday($0)
            }
        }
        .card()
    }

    // MARK: - Relationship (start date)
    private var relationshipSection: some View {
        VStack(spacing: 0) {
            Button {
                HapticManager.selection()
                withAnimation { showDatePicker.toggle() }
            } label: {
                settingRow(sfIcon: "calendar.heart.fill", color: AppTheme.heartRed, title: "Ngày bắt đầu yêu") {
                    HStack(spacing: 6) {
                        Text(viewModel.formattedStartDate).font(AppTheme.bodyFont()).foregroundStyle(AppTheme.deepRose)
                        Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundStyle(.secondary)
                            .rotationEffect(.degrees(showDatePicker ? 90 : 0))
                    }
                }
            }
            if showDatePicker {
                DatePicker("", selection: $startDate, in: ...Date(), displayedComponents: .date)
                    .datePickerStyle(.graphical).tint(AppTheme.deepRose)
                    .onChange(of: startDate) { viewModel.saveStartDate($0) }
            }
        }
        .card()
    }

    // MARK: - Notification row
    private var notificationRow: some View {
        settingRow(sfIcon: "bell.badge.fill", color: Color(red:1.0,green:0.6,blue:0.1), title: "Thông báo kỷ niệm") {
            HStack(spacing: 8) {
                Circle().fill(notifAuthorized ? Color.green : Color.orange).frame(width: 8, height: 8)
                Text(notifAuthorized ? "Đã bật" : "Chưa bật")
                    .font(AppTheme.captionFont()).foregroundStyle(.secondary)
                if !notifAuthorized {
                    Button("Bật") {
                        Task {
                            _ = await NotificationManager.shared.requestPermission()
                            NotificationManager.shared.scheduleAllReminders(
                                startDate: viewModel.startDate, partnerName: viewModel.partnerName,
                                myBirthday: viewModel.myBirthday, partnerBirthday: viewModel.partnerBirthday,
                                myName: viewModel.myName)
                            checkNotifStatus()
                            HapticManager.notification(.success)
                        }
                    }
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12).padding(.vertical, 5)
                    .background(Capsule().fill(AppTheme.deepRose))
                }
            }
        }
        .card()
    }

    // MARK: - Test notification
    private var testNotifButton: some View {
        Button {
            Task {
                _ = await NotificationManager.shared.requestPermission()
                NotificationManager.shared.sendTestNotification()
                HapticManager.notification(.success)
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "bell.badge").font(.system(size: 16))
                Text("Gửi thông báo thử (5 giây)").font(AppTheme.bodyFont())
            }
            .foregroundStyle(AppTheme.deepRose)
            .frame(maxWidth: .infinity).padding(.vertical, 14)
            .background(RoundedRectangle(cornerRadius: 16)
                .fill(AppTheme.softPink.opacity(0.6))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.deepRose.opacity(0.3), lineWidth: 1)))
        }
    }

    // MARK: - Reset
    private var resetButton: some View {
        Button {
            HapticManager.impact(.heavy); showResetAlert = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "arrow.counterclockwise.circle.fill").font(.system(size: 18))
                Text("Đặt lại từ đầu").font(AppTheme.bodyFont())
            }
            .foregroundStyle(.red)
            .frame(maxWidth: .infinity).padding(.vertical, 15)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.red.opacity(0.08))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.red.opacity(0.2), lineWidth: 1)))
        }
    }

    // MARK: - Reusable rows
    @ViewBuilder
    private func settingRow<T: View>(sfIcon: String, color: Color, title: String, @ViewBuilder trailing: () -> T) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8).fill(color).frame(width: 32, height: 32)
                Image(systemName: sfIcon).font(.system(size: 15, weight: .medium)).foregroundStyle(.white)
            }
            Text(title).font(AppTheme.bodyFont())
            Spacer()
            trailing()
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
    }

    private func birthdayRow(title: String, color: Color,
                              date: Binding<Date>, isSet: Binding<Bool>,
                              showPicker: Binding<Bool>, onSave: @escaping (Date?) -> Void) -> some View {
        VStack(spacing: 0) {
            Button {
                HapticManager.selection()
                withAnimation { showPicker.wrappedValue.toggle() }
            } label: {
                settingRow(sfIcon: "gift.fill", color: color, title: title) {
                    HStack(spacing: 6) {
                        if isSet.wrappedValue {
                            Text(DateCalculator.formattedDate(date.wrappedValue))
                                .font(AppTheme.bodyFont()).foregroundStyle(AppTheme.deepRose)
                            Button { isSet.wrappedValue = false; showPicker.wrappedValue = false; onSave(nil) } label: {
                                Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary).font(.system(size: 16))
                            }
                        } else {
                            Text("Chưa đặt").font(AppTheme.captionFont()).foregroundStyle(.secondary)
                        }
                        Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundStyle(.secondary)
                            .rotationEffect(.degrees(showPicker.wrappedValue ? 90 : 0))
                    }
                }
            }
            if showPicker.wrappedValue {
                DatePicker("", selection: date, in: ...Date(), displayedComponents: .date)
                    .datePickerStyle(.graphical).tint(AppTheme.deepRose).padding(.horizontal, 8)
                    .onChange(of: date.wrappedValue) { isSet.wrappedValue = true; onSave($0) }
            }
        }
    }

    private func thinDivider() -> some View {
        Divider().padding(.leading, 62)
    }

    private func label(_ emoji: String, _ text: String) -> some View {
        HStack(spacing: 8) {
            Text(emoji)
            Text(text).font(AppTheme.headlineFont()).foregroundStyle(AppTheme.deepRose)
        }
    }

    // MARK: - Helpers
    private func checkNotifStatus() {
        Task {
            let s = await NotificationManager.shared.authorizationStatus()
            await MainActor.run { notifAuthorized = (s == .authorized) }
        }
    }

    private func resetAll() {
        viewModel.performReset()
        myName = ""; partnerName = ""; startDate = Date()
        myBirthdaySet = false; partnerBirthdaySet = false
        showMyBirthdayPicker = false; showPartnerBirthdayPicker = false
    }
}

private extension View {
    func card() -> some View {
        self.background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppTheme.cardGradient)
                .shadow(color: AppTheme.primaryPink.opacity(0.2), radius: 10, y: 4)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
