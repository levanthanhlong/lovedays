import SwiftUI

struct AnniversaryView: View {
    @ObservedObject var viewModel: LoveViewModel
    @State private var showAddEvent = false

    var body: some View {
        ZStack {
            AppTheme.mainGradient.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    header

                    // Love anniversaries
                    sectionLabel("💑 Kỷ niệm yêu")
                    if let monthly = viewModel.nextMonthly {
                        anniversaryCard(anniversary: monthly, icon: "🌙", accent: AppTheme.deepRose)
                    }
                    if let yearly = viewModel.nextYearly {
                        anniversaryCard(anniversary: yearly, icon: "🎊", accent: AppTheme.heartRed)
                    }

                    // Birthdays
                    sectionLabel("🎂 Sinh nhật")
                    birthdaySection

                    // Custom events
                    sectionLabel("📌 Sự kiện sắp tới")
                    customEventsSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showAddEvent) {
            AddEventView { event in
                viewModel.addCustomEvent(event)
            }
        }
    }

    // MARK: - Header
    private var header: some View {
        TabHeader(emoji: "🎊", title: "Kỷ niệm",
                  subtitle: "Những ngày đặc biệt sắp tới")
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(AppTheme.headlineFont())
            .foregroundStyle(AppTheme.deepRose)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
            .padding(.top, 4)
    }

    // MARK: - Anniversary card (shared for love anniversaries, birthdays, custom events)
    private func anniversaryCard(anniversary: Anniversary, icon: String, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(icon).font(.system(size: 36))
                VStack(alignment: .leading, spacing: 4) {
                    Text(anniversary.title)
                        .font(AppTheme.headlineFont())
                        .foregroundStyle(accent)
                    Text(DateCalculator.formattedDate(anniversary.date, format: "EEEE, dd 'tháng' MM yyyy"))
                        .font(AppTheme.captionFont())
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            Divider()

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Còn lại")
                        .font(AppTheme.captionFont())
                        .foregroundStyle(.secondary)
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(anniversary.daysUntil)")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundStyle(accent)
                        Text("ngày")
                            .font(AppTheme.bodyFont())
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                if anniversary.daysUntil == 0 {
                    Text("🎉 Hôm nay!")
                        .font(AppTheme.headlineFont())
                        .foregroundStyle(accent)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(accent.opacity(0.15)))
                }
            }
        }
        .cardStyle()
    }

    // MARK: - Birthday section
    private var birthdaySection: some View {
        Group {
            if viewModel.nextMyBirthday == nil && viewModel.nextPartnerBirthday == nil {
                noBirthdayHint
            } else {
                VStack(spacing: 16) {
                    if let bd = viewModel.nextMyBirthday {
                        anniversaryCard(anniversary: bd, icon: "🎂", accent: AppTheme.roseGold)
                    }
                    if let bd = viewModel.nextPartnerBirthday {
                        anniversaryCard(anniversary: bd, icon: "🎁", accent: Color(red: 0.5, green: 0.3, blue: 0.8))
                    }
                }
            }
        }
    }

    private var noBirthdayHint: some View {
        HStack(spacing: 14) {
            Text("🎂").font(.system(size: 32))
            VStack(alignment: .leading, spacing: 4) {
                Text("Chưa có ngày sinh")
                    .font(AppTheme.bodyFont())
                    .foregroundStyle(AppTheme.deepRose)
                Text("Thêm ngày sinh trong tab Cài đặt")
                    .font(AppTheme.captionFont())
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .cardStyle()
    }

    // MARK: - Custom events section
    private var customEventsSection: some View {
        VStack(spacing: 16) {
            let upcoming = upcomingCustomEvents
            if upcoming.isEmpty {
                noEventsHint
            } else {
                ForEach(upcoming, id: \.event.id) { item in
                    anniversaryCard(
                        anniversary: Anniversary(title: item.event.title,
                                                date: item.event.date,
                                                daysUntil: item.daysUntil,
                                                isMonthly: false),
                        icon: item.event.icon,
                        accent: AppTheme.deepRose
                    )
                    .contextMenu {
                        Button(role: .destructive) {
                            viewModel.deleteCustomEvent(id: item.event.id)
                        } label: {
                            Label("Xóa sự kiện", systemImage: "trash")
                        }
                    }
                }
            }

            addEventButton
        }
    }

    private var noEventsHint: some View {
        HStack(spacing: 14) {
            Text("📌").font(.system(size: 32))
            VStack(alignment: .leading, spacing: 4) {
                Text("Chưa có sự kiện nào")
                    .font(AppTheme.bodyFont())
                    .foregroundStyle(AppTheme.deepRose)
                Text("Nhấn nút bên dưới để tạo sự kiện mới")
                    .font(AppTheme.captionFont())
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .cardStyle()
    }

    private var addEventButton: some View {
        Button {
            HapticManager.impact(.light)
            showAddEvent = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20))
                Text("Tạo sự kiện mới")
                    .font(AppTheme.bodyFont())
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppTheme.heroGradient)
                    .shadow(color: AppTheme.heartRed.opacity(0.35), radius: 8, y: 4)
            )
        }
    }

    // MARK: - Helpers
    private var upcomingCustomEvents: [(event: CustomEvent, daysUntil: Int)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return viewModel.customEvents
            .filter { calendar.startOfDay(for: $0.date) >= today }
            .map { ($0, DateCalculator.daysUntil($0.date)) }
            .sorted { $0.1 < $1.1 }
    }
}
