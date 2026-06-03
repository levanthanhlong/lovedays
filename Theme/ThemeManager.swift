import SwiftUI

enum AppThemeStyle: String, CaseIterable, Codable {
    case rose, lavender, ocean, forest, sunset, gold

    var displayName: String {
        switch self {
        case .rose:     return "Hồng"
        case .lavender: return "Tím"
        case .ocean:    return "Biển"
        case .forest:   return "Lá"
        case .sunset:   return "Cam"
        case .gold:     return "Vàng"
        }
    }

    var primary: Color {
        switch self {
        case .rose:     return Color(red: 0.84, green: 0.33, blue: 0.50)
        case .lavender: return Color(red: 0.55, green: 0.35, blue: 0.80)
        case .ocean:    return Color(red: 0.18, green: 0.48, blue: 0.85)
        case .forest:   return Color(red: 0.18, green: 0.58, blue: 0.35)
        case .sunset:   return Color(red: 0.88, green: 0.42, blue: 0.12)
        case .gold:     return Color(red: 0.72, green: 0.52, blue: 0.05)
        }
    }

    var secondary: Color {
        switch self {
        case .rose:     return Color(red: 0.94, green: 0.30, blue: 0.47)
        case .lavender: return Color(red: 0.68, green: 0.45, blue: 0.92)
        case .ocean:    return Color(red: 0.22, green: 0.58, blue: 0.96)
        case .forest:   return Color(red: 0.25, green: 0.70, blue: 0.42)
        case .sunset:   return Color(red: 1.00, green: 0.52, blue: 0.18)
        case .gold:     return Color(red: 0.90, green: 0.68, blue: 0.08)
        }
    }

    var light: Color {
        switch self {
        case .rose:     return Color(red: 1.00, green: 0.88, blue: 0.91)
        case .lavender: return Color(red: 0.92, green: 0.88, blue: 1.00)
        case .ocean:    return Color(red: 0.86, green: 0.93, blue: 1.00)
        case .forest:   return Color(red: 0.88, green: 0.97, blue: 0.90)
        case .sunset:   return Color(red: 1.00, green: 0.92, blue: 0.84)
        case .gold:     return Color(red: 1.00, green: 0.96, blue: 0.80)
        }
    }

    var medium: Color {
        switch self {
        case .rose:     return Color(red: 1.00, green: 0.75, blue: 0.80)
        case .lavender: return Color(red: 0.80, green: 0.70, blue: 0.95)
        case .ocean:    return Color(red: 0.65, green: 0.82, blue: 1.00)
        case .forest:   return Color(red: 0.65, green: 0.90, blue: 0.70)
        case .sunset:   return Color(red: 1.00, green: 0.78, blue: 0.58)
        case .gold:     return Color(red: 1.00, green: 0.88, blue: 0.50)
        }
    }

    var warm: Color {
        switch self {
        case .rose:     return Color(red: 1.00, green: 0.97, blue: 0.95)
        case .lavender: return Color(red: 0.97, green: 0.96, blue: 1.00)
        case .ocean:    return Color(red: 0.95, green: 0.97, blue: 1.00)
        case .forest:   return Color(red: 0.95, green: 0.99, blue: 0.96)
        case .sunset:   return Color(red: 1.00, green: 0.97, blue: 0.94)
        case .gold:     return Color(red: 1.00, green: 0.98, blue: 0.92)
        }
    }

    var neutral: Color {
        switch self {
        case .rose:     return Color(red: 0.91, green: 0.67, blue: 0.63)
        case .lavender: return Color(red: 0.75, green: 0.65, blue: 0.85)
        case .ocean:    return Color(red: 0.55, green: 0.72, blue: 0.90)
        case .forest:   return Color(red: 0.55, green: 0.78, blue: 0.62)
        case .sunset:   return Color(red: 0.90, green: 0.68, blue: 0.48)
        case .gold:     return Color(red: 0.85, green: 0.72, blue: 0.38)
        }
    }

    var mainGradient: LinearGradient {
        LinearGradient(colors: [light, warm], startPoint: .top, endPoint: .bottom)
    }

    var heroGradient: LinearGradient {
        LinearGradient(colors: [primary, secondary], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var cardGradient: LinearGradient {
        LinearGradient(colors: [Color.white.opacity(0.95), light.opacity(0.4)],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var style: AppThemeStyle {
        didSet { UserDefaults.standard.set(style.rawValue, forKey: "app_theme_style") }
    }

    private init() {
        if let raw = UserDefaults.standard.string(forKey: "app_theme_style"),
           let saved = AppThemeStyle(rawValue: raw) {
            style = saved
        } else {
            style = .rose
        }
    }
}
