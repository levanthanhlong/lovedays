import SwiftUI

@main
struct LoveDaysApp: App {
    @StateObject private var viewModel = LoveViewModel()

    init() {
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
        }
    }
}
