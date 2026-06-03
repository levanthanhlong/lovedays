import SwiftUI

enum AppTheme {
    private static var t: AppThemeStyle { ThemeManager.shared.style }

    // MARK: - Colors (dynamic — delegate to current theme)
    static var primaryPink: Color  { t.medium }
    static var softPink: Color     { t.light }
    static var warmWhite: Color    { t.warm }
    static var roseGold: Color     { t.neutral }
    static var deepRose: Color     { t.primary }
    static var heartRed: Color     { t.secondary }

    // MARK: - Gradients
    static var mainGradient: LinearGradient { t.mainGradient }
    static var heroGradient: LinearGradient { t.heroGradient }
    static var cardGradient: LinearGradient { t.cardGradient }

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
    static let cornerRadius: CGFloat      = 24
    static let cardCornerRadius: CGFloat  = 20
    static let cardPadding: CGFloat       = 24
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
