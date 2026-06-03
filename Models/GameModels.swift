import Foundation

struct Game2048Record: Identifiable, Codable {
    let id: UUID
    let date: Date
    let score: Int
    let maxTile: Int
    let duration: TimeInterval
    let won: Bool
}

struct GameInfo: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let icon: String
    let color: String // hex
}
