import SwiftUI

struct TabHeader<Trailing: View>: View {
    let emoji: String
    let title: String
    var subtitle: String? = nil
    @ViewBuilder var trailing: () -> Trailing

    var body: some View {
        ZStack(alignment: .trailing) {
            // Card background
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [
                            AppTheme.deepRose.opacity(0.18),
                            AppTheme.softPink.opacity(0.45),
                            AppTheme.warmWhite.opacity(0.6)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(AppTheme.primaryPink.opacity(0.25), lineWidth: 1)
                )
                .shadow(color: AppTheme.deepRose.opacity(0.12), radius: 14, x: 0, y: 6)

            // Decorative large emoji (background layer)
            Text(emoji)
                .font(.system(size: 86))
                .opacity(0.10)
                .offset(x: -12, y: 0)

            // Foreground content
            HStack(alignment: .center, spacing: 12) {
                // Icon badge
                ZStack {
                    Circle()
                        .fill(AppTheme.heroGradient)
                        .frame(width: 48, height: 48)
                        .shadow(color: AppTheme.heartRed.opacity(0.3), radius: 8, y: 3)
                    Text(emoji)
                        .font(.system(size: 24))
                }

                // Text
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.deepRose)
                        .lineLimit(1)
                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }

                Spacer()
                trailing()
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
}

// Convenience init for tabs without a trailing button
extension TabHeader where Trailing == EmptyView {
    init(emoji: String, title: String, subtitle: String? = nil) {
        self.emoji = emoji
        self.title = title
        self.subtitle = subtitle
        self.trailing = { EmptyView() }
    }
}
