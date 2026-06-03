import SwiftUI
import UserNotifications

@main
struct LoveDaysApp: App {
    @StateObject private var viewModel = LoveViewModel()
    @ObservedObject private var theme = ThemeManager.shared

    init() {
        UNUserNotificationCenter.current().delegate = NotificationManager.shared
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        UITabBar.appearance().standardAppearance  = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if viewModel.hasCompletedOnboarding {
                    MainView(viewModel: viewModel)
                } else {
                    OnboardingView(viewModel: viewModel)
                }
            }
            .animation(.easeInOut(duration: 0.5), value: viewModel.hasCompletedOnboarding)
            .id(theme.style)  // re-render entire UI on theme change
        }
    }
}
