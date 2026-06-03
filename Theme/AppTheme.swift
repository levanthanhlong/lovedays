import SwiftUI

enum AppTheme {
    // MARK: - Colors
    static let primaryPink    = Color(red: 1.00, green: 0.75, blue: 0.80)
    static let softPink       = Color(red: 1.00, green: 0.88, blue: 0.91)
    static let warmWhite      = Color(red: 1.00, green: 0.97, blue: 0.95)
    static let roseGold       = Color(red: 0.91, green: 0.67, blue: 0.63)
    static let deepRose       = Color(red: 0.84, green: 0.33, blue: 0.50)
    static let heartRed       = Color(red: 0.94, green: 0.30, blue: 0.47)

    // MARK: - Gradients
    static var mainGradient: LinearGradient {
        LinearGradient(colors: [softPink, warmWhite], startPoint: .top, endPoint: .bottom)
    }

    static var heroGradient: LinearGradient {
        LinearGradient(colors: [deepRose, heartRed], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    static var cardGradient: LinearGradient {
        LinearGradient(colors: [Color.white.opacity(0.95), softPink.opacity(0.4)],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    // MARK: - Typography
    static func counterFont(size: CGFloat = 84) -> Font {
        .system(size: size, weight: .black, design: .rounded)
    }
    static func titleFont(size: CGFloat = 28) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }
    static func headlineFont(size: CGFloat = 20) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }
    static func bodyFont(size: CGFloat = 16) -> Font {
        .system(size: size, weight: .medium, design: .rounded)
    }
    static func captionFont(size: CGFloat = 13) -> Font {
        .system(size: size, weight: .regular, design: .rounded)
    }

    // MARK: - Dimensions
    static let cornerRadius: CGFloat = 24
    static let cardCornerRadius: CGFloat = 20
    static let cardPadding: CGFloat = 24
}

extension View {
    func cardStyle() -> some View {
        self
            .padding(AppTheme.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                    .fill(AppTheme.cardGradient)
                    .shadow(color: AppTheme.primaryPink.opacity(0.25), radius: 12, x: 0, y: 6)
            )
    }

    func primaryButtonStyle() -> some View {
        self
            .font(AppTheme.bodyFont())
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppTheme.heroGradient)
                    .shadow(color: AppTheme.heartRed.opacity(0.4), radius: 10, y: 5)
            )
    }
}
