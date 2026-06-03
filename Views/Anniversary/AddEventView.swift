import SwiftUI

struct AddEventView: View {
    @Environment(\.dismiss) private var dismiss
    var onSave: (CustomEvent) -> Void

    @State private var title = ""
    @State private var date = Date()
    @State private var selectedIcon = "🌟"

    private let icons = [
        "🌟", "💍", "🎂", "🎉", "🏖️", "✈️",
        "🎓", "🎁", "💑", "🏠", "🎵", "🌸",
        "🍕", "🎬", "🏃", "💪", "🎮", "📚",
        "🌺", "🦋", "🌈", "🎪", "🎠", "🌙"
    ]

    private let columns = Array(repeating: GridItem(.flexible()), count: 6)

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.mainGradient.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        selectedIconDisplay
                        iconPickerSection
                        titleSection
                        dateSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Tạo sự kiện")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Hủy") { dismiss() }
                        .foregroundStyle(.secondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Lưu") {
                        guard !title.isEmpty else { return }
                        onSave(CustomEvent(title: title, date: date, icon: selectedIcon))
                        dismiss()
                    }
                    .font(AppTheme.bodyFont())
                    .foregroundStyle(title.isEmpty ? .secondary : AppTheme.deepRose)
                    .disabled(title.isEmpty)
                }
            }
        }
    }

    private var selectedIconDisplay: some View {
        Text(selectedIcon)
            .font(.system(size: 64))
            .padding(.top, 8)
    }

    private var iconPickerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Chọn biểu tượng")
                .font(AppTheme.headlineFont())
                .foregroundStyle(AppTheme.deepRose)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(icons, id: \.self) { icon in
                    Button {
                        HapticManager.selection()
                        selectedIcon = icon
                    } label: {
                        Text(icon)
                            .font(.system(size: 28))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(selectedIcon == icon
                                          ? AppTheme.deepRose.opacity(0.15)
                                          : Color.clear)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(selectedIcon == icon
                                            ? AppTheme.deepRose
                                            : Color.clear, lineWidth: 1.5)
                            )
                    }
                }
            }
        }
        .cardStyle()
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tên sự kiện")
                .font(AppTheme.headlineFont())
                .foregroundStyle(AppTheme.deepRose)

            TextField("VD: Lần đầu gặp nhau...", text: $title)
                .font(AppTheme.bodyFont())
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 12).fill(AppTheme.softPink.opacity(0.5)))
        }
        .cardStyle()
    }

    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ngày diễn ra")
                .font(AppTheme.headlineFont())
                .foregroundStyle(AppTheme.deepRose)

            DatePicker("", selection: $date, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .tint(AppTheme.deepRose)
        }
        .cardStyle()
    }
}
