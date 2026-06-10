import SwiftUI
import SpriteKit

struct SaveTheDogView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentLevel: Int
    @State private var currentScene: GameScene
    @State private var sceneId = UUID()
    @State private var gameResult: GameResult?

    enum GameResult { case won, lost }

    init() {
        let saved = UserDefaults.standard.integer(forKey: "saveTheDog_level")
        let lvl = saved > 0 ? min(saved, allLevels.count) : 1
        _currentLevel = State(initialValue: lvl)
        _currentScene = State(initialValue: Self.makeScene(level: lvl))
    }

    var body: some View {
        ZStack {
            SpriteView(scene: currentScene)
                .id(sceneId)
                .ignoresSafeArea()

            topBar

            if let result = gameResult {
                resultOverlay(result)
            }
        }
        .navigationBarHidden(true)
        .onAppear { bindScene(currentScene) }
    }

    // MARK: - Top bar

    private var topBar: some View {
        VStack {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(.black.opacity(0.4))
                        .clipShape(Circle())
                }

                Spacer()

                Text("Level \(currentLevel) / \(allLevels.count)")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(.black.opacity(0.4))
                    .clipShape(Capsule())

                Spacer()

                Color.clear.frame(width: 40, height: 40)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            Spacer()
        }
    }

    // MARK: - Result overlay

    @ViewBuilder
    private func resultOverlay(_ result: GameResult) -> some View {
        Color.black.opacity(0.65).ignoresSafeArea()

        VStack(spacing: 20) {
            Text(result == .won ? "🎉" : "😢")
                .font(.system(size: 72))

            Text(result == .won ? "Level \(currentLevel) hoàn thành!" : "Ong đốt mất rồi!")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            if result == .won, currentLevel < allLevels.count {
                Button("Level tiếp theo →") { advance() }
                    .buttonStyle(STDButtonStyle(color: .green))
            } else if result == .won {
                Text("🏆 Hoàn thành tất cả 30 level!")
                    .font(.headline)
                    .foregroundStyle(.yellow)
            }

            Button(result == .won ? "Chơi lại level này" : "Thử lại") { restart() }
                .buttonStyle(STDButtonStyle(color: result == .won ? Color(white: 0.35) : .orange))
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(white: 0.12))
        )
        .padding(.horizontal, 32)
    }

    // MARK: - Actions

    private func advance() {
        let next = currentLevel + 1
        UserDefaults.standard.set(next, forKey: "saveTheDog_level")
        currentLevel = next
        loadScene(level: next)
    }

    private func restart() {
        loadScene(level: currentLevel)
    }

    private func loadScene(level: Int) {
        gameResult = nil
        let scene = Self.makeScene(level: level)
        bindScene(scene)
        currentScene = scene
        sceneId = UUID()
    }

    private func bindScene(_ scene: GameScene) {
        scene.onStateChange = { state in
            DispatchQueue.main.async {
                switch state {
                case .won:  gameResult = .won
                case .lost: gameResult = .lost
                default:    break
                }
            }
        }
    }

    private static func makeScene(level: Int) -> GameScene {
        let config = allLevels[level - 1]
        let size = UIScreen.main.bounds.size
        return GameScene(config: config, size: size)
    }
}

// MARK: - Button style

struct STDButtonStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 28)
            .padding(.vertical, 13)
            .background(color.opacity(configuration.isPressed ? 0.7 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
