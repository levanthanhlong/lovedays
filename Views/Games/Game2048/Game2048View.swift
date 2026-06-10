import SwiftUI

struct Game2048View: View {
    @StateObject private var vm = Game2048ViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showHistory = false
    @State private var showNewGameAlert = false
    @State private var showBackAlert = false

    private let gap: CGFloat = 8

    var body: some View {
        ZStack {
            Color(red: 0.18, green: 0.18, blue: 0.22).ignoresSafeArea()

            VStack(spacing: 12) {
                headerBar
                scoreRow
                boardView
                controlRow
                Spacer()
            }
            .padding(.horizontal, 16)

            if vm.state == .won || vm.state == .lost {
                gameOverOverlay
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showHistory) {
            GameHistoryView(history: vm.history)
        }
        .gesture(
            DragGesture(minimumDistance: 30)
                .onEnded { handleSwipe($0) }
        )
        .alert("Chơi mới?", isPresented: $showNewGameAlert) {
            Button("Chơi mới", role: .destructive) {
                withAnimation(.spring(response: 0.15, dampingFraction: 0.85)) {
                    vm.startNew()
                }
            }
            Button("Huỷ", role: .cancel) {}
        } message: {
            Text("Ván đấu hiện tại sẽ bị xoá.")
        }
        .alert("Thoát game?", isPresented: $showBackAlert) {
            Button("Thoát", role: .destructive) { dismiss() }
            Button("Tiếp tục chơi", role: .cancel) {}
        } message: {
            Text("Điểm cao sẽ được giữ lại.")
        }
    }

    private var headerBar: some View {
        HStack {
            Button { showBackAlert = true } label: {
                Image(systemName: "chevron.left")
                    .font(.title3.bold())
                    .foregroundColor(.white)
            }
            Spacer()
            Text("2048")
                .font(.title2.bold())
                .foregroundColor(.white)
            Spacer()
            Button { showHistory = true } label: {
                Image(systemName: "clock")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.top, 8)
    }

    private var scoreRow: some View {
        HStack(spacing: 12) {
            scoreCard(title: "ĐIỂM", value: vm.score)
            scoreCard(title: "CAO NHẤT", value: vm.bestScore)
        }
    }

    private func scoreCard(title: String, value: Int) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption2.bold())
                .foregroundColor(.white.opacity(0.6))
            Text("\(value)")
                .font(.title3.bold())
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }

    private var boardView: some View {
        GeometryReader { geo in
            let cellSize = (geo.size.width - gap * 5) / 4

            // Background grid — determines board size
            VStack(spacing: gap) {
                ForEach(0..<4, id: \.self) { _ in
                    HStack(spacing: gap) {
                        ForEach(0..<4, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(white: 0.9).opacity(0.15))
                                .frame(width: cellSize, height: cellSize)
                        }
                    }
                }
            }
            .overlay(
                // Tiles with stable IDs — animate position via withAnimation
                ZStack {
                    ForEach(vm.tiles) { tile in
                        TileView(value: tile.value, size: cellSize)
                            .position(
                                x: gap + CGFloat(tile.col) * (cellSize + gap) + cellSize / 2,
                                y: gap + CGFloat(tile.row) * (cellSize + gap) + cellSize / 2
                            )
                            .transition(.scale(scale: 0.5).combined(with: .opacity))
                    }
                }
            )
        }
        .padding(gap)
        .aspectRatio(1, contentMode: .fit)
        .background(Color(red: 0.47, green: 0.43, blue: 0.40))
        .cornerRadius(12)
    }

    private var controlRow: some View {
        HStack(spacing: 12) {
            Button { showNewGameAlert = true } label: {
                Label("Mới", systemImage: "arrow.counterclockwise")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(10)
            }
            Button {
                withAnimation(.spring(response: 0.15, dampingFraction: 0.85)) {
                    vm.undo()
                }
            } label: {
                Label("Hoàn tác", systemImage: "arrow.uturn.backward")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(10)
            }
        }
    }

    private var gameOverOverlay: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
            VStack(spacing: 20) {
                Text(vm.state == .won ? "🎉 Thắng!" : "😢 Thua!")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                Text("Điểm: \(vm.score)")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
                HStack(spacing: 16) {
                    Button("Chơi lại") {
                        withAnimation(.spring(response: 0.15, dampingFraction: 0.85)) {
                            vm.startNew()
                        }
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color(red: 0.94, green: 0.57, blue: 0.26))
                    .cornerRadius(12)

                    Button("Thoát") { dismiss() }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                }
            }
            .padding(32)
            .background(Color(red: 0.25, green: 0.24, blue: 0.29))
            .cornerRadius(20)
        }
    }

    private func handleSwipe(_ value: DragGesture.Value) {
        let dx = value.translation.width
        let dy = value.translation.height
        withAnimation(.spring(response: 0.15, dampingFraction: 0.85)) {
            if abs(dx) > abs(dy) {
                vm.swipe(dx > 0 ? .right : .left)
            } else {
                vm.swipe(dy > 0 ? .down : .up)
            }
        }
    }
}

struct TileView: View {
    let value: Int
    let size: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(tileColor)
            if value > 0 {
                Text(value >= 1000 ? "\(value / 1000)K" : "\(value)")
                    .font(fontSize)
                    .bold()
                    .foregroundColor(textColor)
            }
        }
        .frame(width: size, height: size)
    }

    private var fontSize: Font {
        switch value {
        case 0...99:    return .title2
        case 100...999: return .title3
        default:        return .headline
        }
    }

    private var tileColor: Color {
        switch value {
        case 0:    return Color(white: 0.9).opacity(0.15)
        case 2:    return Color(red: 0.93, green: 0.89, blue: 0.85)
        case 4:    return Color(red: 0.93, green: 0.87, blue: 0.78)
        case 8:    return Color(red: 0.95, green: 0.69, blue: 0.47)
        case 16:   return Color(red: 0.96, green: 0.58, blue: 0.39)
        case 32:   return Color(red: 0.96, green: 0.49, blue: 0.37)
        case 64:   return Color(red: 0.96, green: 0.37, blue: 0.23)
        case 128:  return Color(red: 0.93, green: 0.82, blue: 0.45)
        case 256:  return Color(red: 0.93, green: 0.80, blue: 0.38)
        case 512:  return Color(red: 0.93, green: 0.78, blue: 0.31)
        case 1024: return Color(red: 0.93, green: 0.76, blue: 0.25)
        case 2048: return Color(red: 0.93, green: 0.73, blue: 0.18)
        default:   return Color(red: 0.24, green: 0.23, blue: 0.20)
        }
    }

    private var textColor: Color {
        value <= 4 ? Color(red: 0.47, green: 0.43, blue: 0.40) : .white
    }
}
