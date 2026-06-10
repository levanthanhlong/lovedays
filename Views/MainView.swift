import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel: LoveViewModel

    var body: some View {
        TabView {
            HomeView(viewModel: viewModel)
                .tabItem { Label("Trang chủ", systemImage: "heart.fill") }

            AnniversaryView(viewModel: viewModel)
                .tabItem { Label("Kỷ niệm", systemImage: "calendar.badge.clock") }

            NotesView(viewModel: viewModel)
                .tabItem { Label("Ghi chú", systemImage: "note.text") }

            GamesView()
                .tabItem { Label("Trò chơi", systemImage: "gamecontroller.fill") }

            SettingsView(viewModel: viewModel)
                .tabItem { Label("Cài đặt", systemImage: "gearshape.fill") }
        }
        .tint(AppTheme.deepRose)
    }
}
