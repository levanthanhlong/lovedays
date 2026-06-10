import SwiftUI

struct GamesView: View {
    @StateObject private var vm2048 = Game2048ViewModel()
    @State private var navigate2048 = false
    @State private var navigateSTD = false

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.15, green: 0.15, blue: 0.20), Color(red: 0.22, green: 0.18, blue: 0.25)],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    headerArea
                    ScrollView {
                        VStack(spacing: 16) {
                            game2048Card
                            saveTheDogCard
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    }
                }

                NavigationLink(destination: Game2048View(), isActive: $navigate2048) {
                    EmptyView()
                }
                NavigationLink(destination: SaveTheDogView(), isActive: $navigateSTD) {
                    EmptyView()
                }
            }
            .navigationBarHidden(true)
        }
    }

    private var headerArea: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Trò chơi")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                Text("Cùng nhau chơi nhé 🎮")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
            }
            Spacer()
            Text("🎮")
                .font(.system(size: 40))
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    private var saveTheDogCard: some View {
        Button { navigateSTD = true } label: {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(LinearGradient(
                            colors: [Color(red: 0.25, green: 0.60, blue: 0.95), Color(red: 0.45, green: 0.30, blue: 0.90)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ))
                        .frame(width: 60, height: 60)
                    Text("🐶")
                        .font(.system(size: 32))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Save The Dog")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                    Text("Vẽ tường ngăn ong, bảo vệ chó cưng")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    let saved = UserDefaults.standard.integer(forKey: "saveTheDog_level")
                    if saved > 1 {
                        Text("Đang ở level \(min(saved, allLevels.count))/\(allLevels.count)")
                            .font(.caption.bold())
                            .foregroundColor(Color(red: 0.45, green: 0.85, blue: 1.0))
                    }
                }

                Spacer()

                Image(systemName: "play.fill")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(16)
            .background(Color.white.opacity(0.08))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
    }

    private var game2048Card: some View {
        Button { navigate2048 = true } label: {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(LinearGradient(
                            colors: [Color(red: 0.94, green: 0.57, blue: 0.26), Color(red: 0.93, green: 0.73, blue: 0.18)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ))
                        .frame(width: 60, height: 60)
                    Text("2048")
                        .font(.headline.bold())
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("2048")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                    Text("Ghép các ô số để đạt 2048")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    if vm2048.bestScore > 0 {
                        Text("Điểm cao: \(vm2048.bestScore)")
                            .font(.caption.bold())
                            .foregroundColor(Color(red: 0.94, green: 0.73, blue: 0.26))
                    }
                }

                Spacer()

                Image(systemName: "play.fill")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(16)
            .background(Color.white.opacity(0.08))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
    }
}
