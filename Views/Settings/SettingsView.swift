import SwiftUI
import PhotosUI

struct SettingsView: View {
    @ObservedObject var viewModel: LoveViewModel
    @State private var myName = ""
    @State private var partnerName = ""
    @State private var startDate = Date()
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showDatePicker = false
    @State private var notifStatus: String = "Đang kiểm tra..."
    @State private var showResetAlert = false

    // Birthday state
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
                VStack(spacing: 20) {
                    headerSection
                    namesSection
                    birthdaySection
                    dateSection
                    photoSection
                    notificationSection
                    resetSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            myName      = viewModel.myName
            partnerName = viewModel.partnerName
            startDate   = viewModel.startDate
            if let bd = viewModel.myBirthday {
                myBirthday    = bd
                myBirthdaySet = true
            }
            if let bd = viewModel.partnerBirthday {
                partnerBirthday    = bd
                partnerBirthdaySet = true
            }
            checkNotifications()
        }
        .alert("Xóa dữ liệu?", isPresented: $showResetAlert) {
            Button("Xóa", role: .destructive) { resetAll() }
            Button("Hủy", role: .cancel) {}
        } message: {
            Text("Toàn bộ thông tin và ảnh sẽ bị xóa. Hành động này không thể hoàn tác.")
        }
    }

    // MARK: - Sections
    private var headerSection: some View {
        TabHeader(emoji: "⚙️", title: "Cài đặt",
                  subtitle: "Tùy chỉnh thông tin của bạn")
    }

    private var namesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader("👤 Thông tin")

            nameField("Tên của bạn", icon: "person.fill", text: $myName)
                .onChange(of: myName) { v in viewModel.saveMyName(v) }

            nameField("Tên người ấy", icon: "heart.fill", text: $partnerName)
                .onChange(of: partnerName) { v in viewModel.savePartnerName(v) }
        }
        .cardStyle()
    }

    private var birthdaySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader("🎂 Ngày sinh")

            birthdayRow(
                label: "Ngày sinh của bạn",
                date: $myBirthday,
                isSet: $myBirthdaySet,
                showPicker: $showMyBirthdayPicker
            ) { viewModel.saveMyBirthday($0) }

            birthdayRow(
                label: "Ngày sinh người ấy",
                date: $partnerBirthday,
                isSet: $partnerBirthdaySet,
                showPicker: $showPartnerBirthdayPicker
            ) { viewModel.savePartnerBirthday($0) }
        }
        .cardStyle()
    }

    private func birthdayRow(
        label: String,
        date: Binding<Date>,
        isSet: Binding<Bool>,
        showPicker: Binding<Bool>,
        onSave: @escaping (Date?) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: "gift.fill")
                    .foregroundStyle(AppTheme.deepRose)
                    .frame(width: 22)
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(AppTheme.captionFont())
                        .foregroundStyle(.secondary)
                    Text(isSet.wrappedValue
                         ? DateCalculator.formattedDate(date.wrappedValue)
                         : "Chưa đặt")
                        .font(AppTheme.bodyFont())
                        .foregroundStyle(isSet.wrappedValue ? AppTheme.deepRose : .secondary)
                }
                Spacer()
                if isSet.wrappedValue {
                    Button {
                        isSet.wrappedValue = false
                        showPicker.wrappedValue = false
                        onSave(nil)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .rotationEffect(.degrees(showPicker.wrappedValue ? 90 : 0))
            }
            .contentShape(Rectangle())
            .onTapGesture {
                HapticManager.selection()
                withAnimation { showPicker.wrappedValue.toggle() }
            }

            if showPicker.wrappedValue {
                DatePicker("", selection: date, in: ...Date(), displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .tint(AppTheme.deepRose)
                    .onChange(of: date.wrappedValue) { d in
                        isSet.wrappedValue = true
                        onSave(d)
                    }
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 12).fill(AppTheme.softPink.opacity(0.4)))
    }

    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader("📅 Ngày bắt đầu")

            Button {
                HapticManager.selection()
                showDatePicker.toggle()
            } label: {
                HStack {
                    Text(viewModel.formattedStartDate)
                        .font(AppTheme.bodyFont())
                        .foregroundStyle(AppTheme.deepRose)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(showDatePicker ? 90 : 0))
                }
            }

            if showDatePicker {
                DatePicker("", selection: $startDate, in: ...Date(), displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .tint(AppTheme.deepRose)
                    .onChange(of: startDate) { d in viewModel.saveStartDate(d) }
            }
        }
        .cardStyle()
    }

    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader("🖼 Ảnh đôi")

            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                HStack(spacing: 16) {
                    if let img = viewModel.couplePhoto {
                        Image(uiImage: img)
                            .resizable().scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppTheme.softPink)
                            .frame(width: 60, height: 60)
                            .overlay(Image(systemName: "photo").foregroundStyle(AppTheme.roseGold))
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Đổi ảnh đôi")
                            .font(AppTheme.bodyFont()).foregroundStyle(AppTheme.deepRose)
                        Text("Nhấn để chọn ảnh mới")
                            .font(AppTheme.captionFont()).foregroundStyle(.secondary)
                    }
                    Spacer()
                }
            }
            .onChange(of: selectedPhoto) { item in
                Task {
                    if let data = try? await item?.loadTransferable(type: Data.self) {
                        viewModel.saveCouplePhoto(data)
                    }
                }
            }

            if viewModel.couplePhoto != nil {
                Button {
                    HapticManager.impact(.medium)
                    viewModel.saveCouplePhoto(nil)
                } label: {
                    Label("Xóa ảnh", systemImage: "trash")
                        .font(AppTheme.captionFont())
                        .foregroundStyle(.red.opacity(0.8))
                }
            }
        }
        .cardStyle()
    }

    private var notificationSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader("🔔 Thông báo")
            Text(notifStatus)
                .font(AppTheme.bodyFont())
                .foregroundStyle(.secondary)
            Button {
                Task {
                    _ = await NotificationManager.shared.requestPermission()
                    NotificationManager.shared.scheduleAnniversaryReminders(
                        startDate: viewModel.startDate, partnerName: viewModel.partnerName)
                    checkNotifications()
                    HapticManager.notification(.success)
                }
            } label: {
                Label("Bật thông báo kỷ niệm", systemImage: "bell.badge")
                    .font(AppTheme.bodyFont())
                    .foregroundStyle(AppTheme.deepRose)
            }
        }
        .cardStyle()
    }

    private var resetSection: some View {
        Button {
            HapticManager.impact(.heavy)
            showResetAlert = true
        } label: {
            Label("Đặt lại từ đầu", systemImage: "arrow.counterclockwise")
                .font(AppTheme.bodyFont())
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(RoundedRectangle(cornerRadius: 16)
                    .fill(Color.red.opacity(0.08)))
        }
    }

    // MARK: - Helpers
    private func sectionHeader(_ text: String) -> some View {
        Text(text).font(AppTheme.headlineFont()).foregroundStyle(AppTheme.deepRose)
    }

    private func nameField(_ placeholder: String, icon: String, text: Binding<String>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).foregroundStyle(AppTheme.deepRose).frame(width: 22)
            TextField(placeholder, text: text).font(AppTheme.bodyFont())
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 12).fill(AppTheme.softPink.opacity(0.4)))
    }

    private func checkNotifications() {
        Task {
            let status = await NotificationManager.shared.authorizationStatus()
            await MainActor.run {
                switch status {
                case .authorized: notifStatus = "✅ Đã bật thông báo kỷ niệm"
                case .denied:     notifStatus = "❌ Thông báo bị tắt. Bật trong Settings."
                default:          notifStatus = "⚠️ Chưa cấp quyền thông báo"
                }
            }
        }
    }

    private func resetAll() {
        viewModel.performReset()
        myName              = ""
        partnerName         = ""
        startDate           = Date()
        myBirthdaySet       = false
        partnerBirthdaySet  = false
        showMyBirthdayPicker    = false
        showPartnerBirthdayPicker = false
    }
}
