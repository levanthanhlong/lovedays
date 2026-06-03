import SwiftUI

struct TabHeader<Trailing: View>: View {
    let emoji: String
    let title: String
    var subtitle: String? = nil
    @ViewBuilder var trailing: () -> Trailing

    var body: some View {
        // Content drives height — decoratives are background overlay
        HStack(alignment: .center, spacing: 0) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundStyle(.white.opacity(0.78))
                        .lineLimit(1)
                }
            }
            Spacer()
            trailing().tint(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background {
            ZStack(alignment: .trailing) {
                // Gradient card
                RoundedRectangle(cornerRadius: 20)
                    .fill(LinearGradient(
                        colors: [AppTheme.deepRose, Color(red: 0.94, green: 0.38, blue: 0.54)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
                    .shadow(color: AppTheme.deepRose.opacity(0.4), radius: 12, x: 0, y: 6)

                // Decorative circles
                Circle().fill(.white.opacity(0.07)).frame(width: 80).offset(x: -40, y: -22)
                Circle().fill(.white.opacity(0.05)).frame(width: 50).offset(x: -20, y: 20)

                // Watermark emoji — clipped inside card
                Text(emoji)
                    .font(.system(size: 70))
                    .opacity(0.14)
                    .offset(x: -10)
                    .clipped()
            }
        }
    }
}

extension TabHeader where Trailing == EmptyView {
    init(emoji: String, title: String, subtitle: String? = nil) {
        self.emoji = emoji; self.title = title; self.subtitle = subtitle
        self.trailing = { EmptyView() }
    }
}
