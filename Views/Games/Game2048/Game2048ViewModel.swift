import Foundation

enum SwipeDirection { case up, down, left, right }
enum GameState { case playing, won, lost }

struct Tile2048: Identifiable {
    let id: UUID
    var value: Int
    var row: Int
    var col: Int
}

class Game2048ViewModel: ObservableObject {
    @Published var tiles: [Tile2048] = []
    @Published var score: Int = 0
    @Published var bestScore: Int = 0
    @Published var state: GameState = .playing
    @Published var history: [Game2048Record] = []

    private var previousTiles: [Tile2048] = []
    private var previousScore: Int = 0
    private var startTime: Date = Date()
    private let recordsKey = "game2048_records"
    private let bestKey = "game2048_best"

    init() {
        bestScore = UserDefaults.standard.integer(forKey: bestKey)
        loadHistory()
        startNew()
    }

    func startNew() {
        tiles = []
        score = 0
        state = .playing
        startTime = Date()
        addRandom()
        addRandom()
    }

    func swipe(_ direction: SwipeDirection) {
        guard state == .playing else { return }
        let oldBoard = boardArray(from: tiles)
        previousTiles = tiles
        previousScore = score

        var updated: [UUID: Tile2048] = Dictionary(uniqueKeysWithValues: tiles.map { ($0.id, $0) })
        var allRemoved: Set<UUID> = []
        var gained = 0

        switch direction {
        case .left:
            for row in 0..<4 {
                let group = tiles.filter { $0.row == row }
                let (kept, removed, g) = mergeGroup(group.sorted { $0.col < $1.col }) { t, i in
                    var t2 = t; t2.col = i; return t2
                }
                kept.forEach { updated[$0.id] = $0 }
                allRemoved.formUnion(removed)
                gained += g
            }
        case .right:
            for row in 0..<4 {
                let group = tiles.filter { $0.row == row }
                let (kept, removed, g) = mergeGroup(group.sorted { $0.col > $1.col }) { t, i in
                    var t2 = t; t2.col = 3 - i; return t2
                }
                kept.forEach { updated[$0.id] = $0 }
                allRemoved.formUnion(removed)
                gained += g
            }
        case .up:
            for col in 0..<4 {
                let group = tiles.filter { $0.col == col }
                let (kept, removed, g) = mergeGroup(group.sorted { $0.row < $1.row }) { t, i in
                    var t2 = t; t2.row = i; return t2
                }
                kept.forEach { updated[$0.id] = $0 }
                allRemoved.formUnion(removed)
                gained += g
            }
        case .down:
            for col in 0..<4 {
                let group = tiles.filter { $0.col == col }
                let (kept, removed, g) = mergeGroup(group.sorted { $0.row > $1.row }) { t, i in
                    var t2 = t; t2.row = 3 - i; return t2
                }
                kept.forEach { updated[$0.id] = $0 }
                allRemoved.formUnion(removed)
                gained += g
            }
        }

        let newTiles = updated.values.filter { !allRemoved.contains($0.id) }
        guard boardArray(from: Array(newTiles)) != oldBoard else { return }

        tiles = Array(newTiles)
        score += gained
        if score > bestScore {
            bestScore = score
            UserDefaults.standard.set(bestScore, forKey: bestKey)
        }

        if tiles.contains(where: { $0.value == 2048 }) {
            state = .won
            saveRecord(won: true)
            return
        }

        addRandom()

        if isLost() {
            state = .lost
            saveRecord(won: false)
        }
    }

    func undo() {
        guard !previousTiles.isEmpty else { return }
        tiles = previousTiles
        score = previousScore
        state = .playing
        previousTiles = []
    }

    private func mergeGroup(
        _ sorted: [Tile2048],
        assignIndex: (Tile2048, Int) -> Tile2048
    ) -> (kept: [Tile2048], removed: Set<UUID>, gained: Int) {
        var result: [Tile2048] = []
        var removed: Set<UUID> = []
        var gained = 0
        var i = 0
        while i < sorted.count {
            if i + 1 < sorted.count && sorted[i].value == sorted[i + 1].value {
                var merged = sorted[i]
                merged.value *= 2
                gained += merged.value
                result.append(merged)
                removed.insert(sorted[i + 1].id)
                i += 2
            } else {
                result.append(sorted[i])
                i += 1
            }
        }
        let final = result.enumerated().map { assignIndex($0.element, $0.offset) }
        return (final, removed, gained)
    }

    private func addRandom() {
        let occupied = Set(tiles.map { $0.row * 4 + $0.col })
        var empty: [(Int, Int)] = []
        for r in 0..<4 {
            for c in 0..<4 {
                if !occupied.contains(r * 4 + c) { empty.append((r, c)) }
            }
        }
        guard let (r, c) = empty.randomElement() else { return }
        tiles.append(Tile2048(id: UUID(), value: Int.random(in: 1...10) == 1 ? 4 : 2, row: r, col: c))
    }

    private func isLost() -> Bool {
        if tiles.count < 16 { return false }
        let b = boardArray(from: tiles)
        for r in 0..<4 {
            for c in 0..<4 {
                if c < 3 && b[r][c] == b[r][c + 1] { return false }
                if r < 3 && b[r][c] == b[r + 1][c] { return false }
            }
        }
        return true
    }

    private func boardArray(from tileArr: [Tile2048]) -> [[Int]] {
        var b = Array(repeating: Array(repeating: 0, count: 4), count: 4)
        for t in tileArr { b[t.row][t.col] = t.value }
        return b
    }

    private func saveRecord(won: Bool) {
        let b = boardArray(from: tiles)
        let record = Game2048Record(
            id: UUID(),
            date: Date(),
            score: score,
            maxTile: b.flatMap { $0 }.max() ?? 0,
            duration: Date().timeIntervalSince(startTime),
            won: won
        )
        history.insert(record, at: 0)
        if history.count > 20 { history = Array(history.prefix(20)) }
        if let data = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(data, forKey: recordsKey)
        }
    }

    private func loadHistory() {
        guard let data = UserDefaults.standard.data(forKey: recordsKey),
              let records = try? JSONDecoder().decode([Game2048Record].self, from: data) else { return }
        history = records
    }
}
