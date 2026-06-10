import CoreGraphics

enum HazardType: String {
    case spike = "⚡", water = "💧", bomb = "💣"
}

struct PlatformData {
    let rect: CGRect // normalized 0-1, origin = bottom-left corner
}

struct HazardData {
    let position: CGPoint // normalized 0-1
    let type: HazardType
}

struct LevelConfig {
    let level: Int
    let dogPositions: [CGPoint]
    let beehivePositions: [CGPoint]
    let platforms: [PlatformData]
    let hazards: [HazardData]
    let beeCount: Int
    let hasQueenBee: Bool
}

// swiftlint:disable line_length
private let handCraftedLevels: [LevelConfig] = [
    // 1: Flat ground, dog center, 1 hive top-right
    LevelConfig(level: 1, dogPositions: [.init(x: 0.5, y: 0.12)], beehivePositions: [.init(x: 0.85, y: 0.85)], platforms: [PlatformData(rect: .init(x: 0.05, y: 0.28, width: 0.25, height: 0.04)), PlatformData(rect: .init(x: 0.7, y: 0.32, width: 0.25, height: 0.04))], hazards: [], beeCount: 2, hasQueenBee: false),

    // 2: Dog on low platform center, hive top-left
    LevelConfig(level: 2, dogPositions: [.init(x: 0.5, y: 0.38)], beehivePositions: [.init(x: 0.15, y: 0.85)], platforms: [PlatformData(rect: .init(x: 0.3, y: 0.28, width: 0.4, height: 0.05))], hazards: [], beeCount: 2, hasQueenBee: false),

    // 3: Dog bottom-left, vertical wall right, hive above
    LevelConfig(level: 3, dogPositions: [.init(x: 0.2, y: 0.12)], beehivePositions: [.init(x: 0.5, y: 0.85)], platforms: [PlatformData(rect: .init(x: 0.55, y: 0.1, width: 0.04, height: 0.5))], hazards: [], beeCount: 3, hasQueenBee: false),

    // 4: Dog between 2 columns, hive top center
    LevelConfig(level: 4, dogPositions: [.init(x: 0.5, y: 0.12)], beehivePositions: [.init(x: 0.5, y: 0.88)], platforms: [PlatformData(rect: .init(x: 0.25, y: 0.1, width: 0.04, height: 0.4)), PlatformData(rect: .init(x: 0.71, y: 0.1, width: 0.04, height: 0.4))], hazards: [], beeCount: 3, hasQueenBee: false),

    // 5: Dog on high platform, spikes below
    LevelConfig(level: 5, dogPositions: [.init(x: 0.5, y: 0.68)], beehivePositions: [.init(x: 0.85, y: 0.85)], platforms: [PlatformData(rect: .init(x: 0.3, y: 0.58, width: 0.4, height: 0.05))], hazards: [.init(position: .init(x: 0.3, y: 0.1), type: .spike), .init(position: .init(x: 0.5, y: 0.1), type: .spike), .init(position: .init(x: 0.7, y: 0.1), type: .spike)], beeCount: 3, hasQueenBee: false),

    // 6: Dog bottom, horizontal wall mid, hive top
    LevelConfig(level: 6, dogPositions: [.init(x: 0.5, y: 0.12)], beehivePositions: [.init(x: 0.5, y: 0.9)], platforms: [PlatformData(rect: .init(x: 0.1, y: 0.48, width: 0.8, height: 0.04))], hazards: [], beeCount: 3, hasQueenBee: false),

    // 7: Dog narrow platform, 2 hives top corners
    LevelConfig(level: 7, dogPositions: [.init(x: 0.5, y: 0.45)], beehivePositions: [.init(x: 0.1, y: 0.85), .init(x: 0.9, y: 0.85)], platforms: [PlatformData(rect: .init(x: 0.4, y: 0.36, width: 0.2, height: 0.04))], hazards: [], beeCount: 4, hasQueenBee: false),

    // 8: Dog in left alcove, bees from right
    LevelConfig(level: 8, dogPositions: [.init(x: 0.15, y: 0.5)], beehivePositions: [.init(x: 0.85, y: 0.5)], platforms: [PlatformData(rect: .init(x: 0.05, y: 0.36, width: 0.25, height: 0.04)), PlatformData(rect: .init(x: 0.05, y: 0.62, width: 0.25, height: 0.04))], hazards: [], beeCount: 4, hasQueenBee: false),

    // 9: Dog center, hive top
    LevelConfig(level: 9, dogPositions: [.init(x: 0.5, y: 0.52)], beehivePositions: [.init(x: 0.5, y: 0.88)], platforms: [PlatformData(rect: .init(x: 0.3, y: 0.42, width: 0.4, height: 0.04))], hazards: [], beeCount: 4, hasQueenBee: false),

    // 10: Dog mid-air platform, 2 hives left/right
    LevelConfig(level: 10, dogPositions: [.init(x: 0.5, y: 0.55)], beehivePositions: [.init(x: 0.1, y: 0.5), .init(x: 0.9, y: 0.5)], platforms: [PlatformData(rect: .init(x: 0.35, y: 0.46, width: 0.3, height: 0.04))], hazards: [], beeCount: 4, hasQueenBee: false),

    // 11: Dog corner, spikes walls, bees from top
    LevelConfig(level: 11, dogPositions: [.init(x: 0.15, y: 0.12)], beehivePositions: [.init(x: 0.5, y: 0.9)], platforms: [PlatformData(rect: .init(x: 0.0, y: 0.28, width: 0.3, height: 0.04)), PlatformData(rect: .init(x: 0.7, y: 0.28, width: 0.3, height: 0.04)), PlatformData(rect: .init(x: 0.35, y: 0.52, width: 0.3, height: 0.04))], hazards: [.init(position: .init(x: 0.05, y: 0.4), type: .spike), .init(position: .init(x: 0.95, y: 0.4), type: .spike)], beeCount: 5, hasQueenBee: false),

    // 12: Dog on platform, water below, 2 hives top
    LevelConfig(level: 12, dogPositions: [.init(x: 0.5, y: 0.55)], beehivePositions: [.init(x: 0.15, y: 0.85), .init(x: 0.85, y: 0.85)], platforms: [PlatformData(rect: .init(x: 0.3, y: 0.46, width: 0.4, height: 0.04))], hazards: [.init(position: .init(x: 0.25, y: 0.1), type: .water), .init(position: .init(x: 0.5, y: 0.1), type: .water), .init(position: .init(x: 0.75, y: 0.1), type: .water)], beeCount: 5, hasQueenBee: false),

    // 13: Dog between 2 platforms, 3 hives
    LevelConfig(level: 13, dogPositions: [.init(x: 0.5, y: 0.55)], beehivePositions: [.init(x: 0.1, y: 0.85), .init(x: 0.5, y: 0.9), .init(x: 0.9, y: 0.85)], platforms: [PlatformData(rect: .init(x: 0.1, y: 0.46, width: 0.3, height: 0.04)), PlatformData(rect: .init(x: 0.6, y: 0.46, width: 0.3, height: 0.04))], hazards: [], beeCount: 5, hasQueenBee: false),

    // 14: Dog in alcove, bomb, 2 hives
    LevelConfig(level: 14, dogPositions: [.init(x: 0.15, y: 0.5)], beehivePositions: [.init(x: 0.7, y: 0.3), .init(x: 0.7, y: 0.7)], platforms: [PlatformData(rect: .init(x: 0.05, y: 0.36, width: 0.25, height: 0.04)), PlatformData(rect: .init(x: 0.05, y: 0.62, width: 0.25, height: 0.04))], hazards: [.init(position: .init(x: 0.5, y: 0.88), type: .bomb)], beeCount: 5, hasQueenBee: false),

    // 15: Dog high platform, spikes, 2 hives
    LevelConfig(level: 15, dogPositions: [.init(x: 0.5, y: 0.68)], beehivePositions: [.init(x: 0.2, y: 0.85), .init(x: 0.85, y: 0.85)], platforms: [PlatformData(rect: .init(x: 0.3, y: 0.58, width: 0.4, height: 0.04))], hazards: [.init(position: .init(x: 0.4, y: 0.1), type: .spike), .init(position: .init(x: 0.6, y: 0.1), type: .spike), .init(position: .init(x: 0.85, y: 0.1), type: .spike)], beeCount: 5, hasQueenBee: false),

    // 16: Dog center, bomb top, 3 hives
    LevelConfig(level: 16, dogPositions: [.init(x: 0.5, y: 0.12)], beehivePositions: [.init(x: 0.1, y: 0.85), .init(x: 0.5, y: 0.9), .init(x: 0.9, y: 0.85)], platforms: [PlatformData(rect: .init(x: 0.1, y: 0.30, width: 0.25, height: 0.04)), PlatformData(rect: .init(x: 0.65, y: 0.30, width: 0.25, height: 0.04)), PlatformData(rect: .init(x: 0.38, y: 0.45, width: 0.24, height: 0.04))], hazards: [.init(position: .init(x: 0.5, y: 0.88), type: .bomb)], beeCount: 6, hasQueenBee: false),

    // 17: Dog over water, 2 hives sides
    LevelConfig(level: 17, dogPositions: [.init(x: 0.5, y: 0.55)], beehivePositions: [.init(x: 0.1, y: 0.55), .init(x: 0.9, y: 0.55)], platforms: [PlatformData(rect: .init(x: 0.35, y: 0.46, width: 0.3, height: 0.04))], hazards: [.init(position: .init(x: 0.15, y: 0.1), type: .water), .init(position: .init(x: 0.35, y: 0.1), type: .water), .init(position: .init(x: 0.55, y: 0.1), type: .water), .init(position: .init(x: 0.75, y: 0.1), type: .water)], beeCount: 6, hasQueenBee: false),

    // 18: Dog corner, spikes, bees 2 sides
    LevelConfig(level: 18, dogPositions: [.init(x: 0.15, y: 0.12)], beehivePositions: [.init(x: 0.85, y: 0.12), .init(x: 0.85, y: 0.85)], platforms: [PlatformData(rect: .init(x: 0.0, y: 0.28, width: 0.28, height: 0.04)), PlatformData(rect: .init(x: 0.4, y: 0.45, width: 0.3, height: 0.04))], hazards: [.init(position: .init(x: 0.15, y: 0.3), type: .spike)], beeCount: 6, hasQueenBee: false),

    // 19: 2 dogs corners, 3 hives
    LevelConfig(level: 19, dogPositions: [.init(x: 0.15, y: 0.12), .init(x: 0.85, y: 0.85)], beehivePositions: [.init(x: 0.5, y: 0.5), .init(x: 0.85, y: 0.12), .init(x: 0.15, y: 0.85)], platforms: [PlatformData(rect: .init(x: 0.0, y: 0.28, width: 0.32, height: 0.04)), PlatformData(rect: .init(x: 0.68, y: 0.7, width: 0.32, height: 0.04))], hazards: [], beeCount: 6, hasQueenBee: false),

    // 20: Dog narrow platform, bomb+spikes+3 hives
    LevelConfig(level: 20, dogPositions: [.init(x: 0.5, y: 0.55)], beehivePositions: [.init(x: 0.1, y: 0.85), .init(x: 0.5, y: 0.9), .init(x: 0.9, y: 0.85)], platforms: [PlatformData(rect: .init(x: 0.4, y: 0.46, width: 0.2, height: 0.04))], hazards: [.init(position: .init(x: 0.5, y: 0.85), type: .bomb), .init(position: .init(x: 0.2, y: 0.1), type: .spike), .init(position: .init(x: 0.8, y: 0.1), type: .spike)], beeCount: 7, hasQueenBee: false),

    // 21: 2 dogs, spikes 2 sides
    LevelConfig(level: 21, dogPositions: [.init(x: 0.35, y: 0.12), .init(x: 0.65, y: 0.12)], beehivePositions: [.init(x: 0.15, y: 0.85), .init(x: 0.5, y: 0.9), .init(x: 0.85, y: 0.85)], platforms: [PlatformData(rect: .init(x: 0.05, y: 0.30, width: 0.3, height: 0.04)), PlatformData(rect: .init(x: 0.65, y: 0.30, width: 0.3, height: 0.04))], hazards: [.init(position: .init(x: 0.05, y: 0.3), type: .spike), .init(position: .init(x: 0.95, y: 0.3), type: .spike)], beeCount: 7, hasQueenBee: false),

    // 22: Dog in maze area, 3 hives
    LevelConfig(level: 22, dogPositions: [.init(x: 0.5, y: 0.5)], beehivePositions: [.init(x: 0.1, y: 0.85), .init(x: 0.9, y: 0.15), .init(x: 0.5, y: 0.9)], platforms: [PlatformData(rect: .init(x: 0.2, y: 0.36, width: 0.25, height: 0.04)), PlatformData(rect: .init(x: 0.55, y: 0.36, width: 0.25, height: 0.04)), PlatformData(rect: .init(x: 0.2, y: 0.62, width: 0.25, height: 0.04)), PlatformData(rect: .init(x: 0.55, y: 0.62, width: 0.25, height: 0.04))], hazards: [], beeCount: 7, hasQueenBee: false),

    // 23: Dog on small platform, 2 bombs, 3 hives
    LevelConfig(level: 23, dogPositions: [.init(x: 0.5, y: 0.55)], beehivePositions: [.init(x: 0.1, y: 0.85), .init(x: 0.9, y: 0.85), .init(x: 0.5, y: 0.9)], platforms: [PlatformData(rect: .init(x: 0.42, y: 0.46, width: 0.16, height: 0.04))], hazards: [.init(position: .init(x: 0.25, y: 0.88), type: .bomb), .init(position: .init(x: 0.75, y: 0.88), type: .bomb)], beeCount: 8, hasQueenBee: false),

    // 24: 2 dogs protect, 3 hives
    LevelConfig(level: 24, dogPositions: [.init(x: 0.2, y: 0.12), .init(x: 0.8, y: 0.12)], beehivePositions: [.init(x: 0.1, y: 0.85), .init(x: 0.5, y: 0.9), .init(x: 0.9, y: 0.85)], platforms: [PlatformData(rect: .init(x: 0.35, y: 0.30, width: 0.3, height: 0.04))], hazards: [], beeCount: 8, hasQueenBee: false),

    // 25: Dog on platform, water hazards, 3 hives
    LevelConfig(level: 25, dogPositions: [.init(x: 0.5, y: 0.55)], beehivePositions: [.init(x: 0.15, y: 0.85), .init(x: 0.5, y: 0.9), .init(x: 0.85, y: 0.85)], platforms: [PlatformData(rect: .init(x: 0.3, y: 0.46, width: 0.4, height: 0.04))], hazards: [.init(position: .init(x: 0.15, y: 0.1), type: .water), .init(position: .init(x: 0.35, y: 0.1), type: .water), .init(position: .init(x: 0.55, y: 0.1), type: .water), .init(position: .init(x: 0.75, y: 0.1), type: .water)], beeCount: 8, hasQueenBee: false),

    // 26: Queen bee + 3 hives, spikes
    LevelConfig(level: 26, dogPositions: [.init(x: 0.5, y: 0.12)], beehivePositions: [.init(x: 0.5, y: 0.9), .init(x: 0.15, y: 0.7), .init(x: 0.85, y: 0.7)], platforms: [PlatformData(rect: .init(x: 0.05, y: 0.35, width: 0.3, height: 0.04)), PlatformData(rect: .init(x: 0.65, y: 0.35, width: 0.3, height: 0.04))], hazards: [.init(position: .init(x: 0.2, y: 0.1), type: .spike), .init(position: .init(x: 0.8, y: 0.1), type: .spike)], beeCount: 8, hasQueenBee: true),

    // 27: Dog narrow platform, water+bomb, queen bee
    LevelConfig(level: 27, dogPositions: [.init(x: 0.5, y: 0.55)], beehivePositions: [.init(x: 0.15, y: 0.85), .init(x: 0.5, y: 0.9), .init(x: 0.85, y: 0.85)], platforms: [PlatformData(rect: .init(x: 0.42, y: 0.46, width: 0.16, height: 0.04))], hazards: [.init(position: .init(x: 0.85, y: 0.1), type: .water), .init(position: .init(x: 0.5, y: 0.85), type: .bomb)], beeCount: 9, hasQueenBee: true),

    // 28: 2 dogs platforms, spikes+4 hives
    LevelConfig(level: 28, dogPositions: [.init(x: 0.2, y: 0.55), .init(x: 0.8, y: 0.55)], beehivePositions: [.init(x: 0.1, y: 0.9), .init(x: 0.4, y: 0.9), .init(x: 0.6, y: 0.9), .init(x: 0.9, y: 0.9)], platforms: [PlatformData(rect: .init(x: 0.05, y: 0.46, width: 0.3, height: 0.04)), PlatformData(rect: .init(x: 0.65, y: 0.46, width: 0.3, height: 0.04))], hazards: [.init(position: .init(x: 0.3, y: 0.1), type: .spike), .init(position: .init(x: 0.7, y: 0.1), type: .spike)], beeCount: 9, hasQueenBee: false),

    // 29: Complex terrain, queen bee + bomb
    LevelConfig(level: 29, dogPositions: [.init(x: 0.5, y: 0.12)], beehivePositions: [.init(x: 0.15, y: 0.85), .init(x: 0.5, y: 0.9), .init(x: 0.85, y: 0.85)], platforms: [PlatformData(rect: .init(x: 0.15, y: 0.46, width: 0.3, height: 0.04)), PlatformData(rect: .init(x: 0.55, y: 0.46, width: 0.3, height: 0.04))], hazards: [.init(position: .init(x: 0.5, y: 0.85), type: .bomb)], beeCount: 10, hasQueenBee: true),

    // 30: Boss — everything
    LevelConfig(level: 30, dogPositions: [.init(x: 0.25, y: 0.12), .init(x: 0.75, y: 0.12)], beehivePositions: [.init(x: 0.1, y: 0.85), .init(x: 0.35, y: 0.9), .init(x: 0.65, y: 0.9), .init(x: 0.9, y: 0.85)], platforms: [PlatformData(rect: .init(x: 0.1, y: 0.36, width: 0.3, height: 0.04)), PlatformData(rect: .init(x: 0.6, y: 0.36, width: 0.3, height: 0.04))], hazards: [.init(position: .init(x: 0.4, y: 0.1), type: .water), .init(position: .init(x: 0.8, y: 0.1), type: .water), .init(position: .init(x: 0.5, y: 0.85), type: .bomb)], beeCount: 12, hasQueenBee: true),
]
// swiftlint:enable line_length

// MARK: - Procedural levels (31-100)

private let levelTemplates: [(dogs: [CGPoint], hives: [CGPoint], platforms: [PlatformData])] = [
    // Floor guard
    (dogs: [.init(x: 0.5, y: 0.12)],
     hives: [.init(x: 0.15, y: 0.85), .init(x: 0.85, y: 0.85)],
     platforms: [PlatformData(rect: .init(x: 0.3, y: 0.30, width: 0.4, height: 0.04))]),

    // Elevated dog
    (dogs: [.init(x: 0.5, y: 0.55)],
     hives: [.init(x: 0.1, y: 0.5), .init(x: 0.9, y: 0.5)],
     platforms: [PlatformData(rect: .init(x: 0.35, y: 0.46, width: 0.3, height: 0.04))]),

    // Twin guardians
    (dogs: [.init(x: 0.2, y: 0.12), .init(x: 0.8, y: 0.12)],
     hives: [.init(x: 0.1, y: 0.85), .init(x: 0.5, y: 0.9), .init(x: 0.9, y: 0.85)],
     platforms: [PlatformData(rect: .init(x: 0.35, y: 0.30, width: 0.3, height: 0.04))]),

    // High perch
    (dogs: [.init(x: 0.5, y: 0.68)],
     hives: [.init(x: 0.2, y: 0.85), .init(x: 0.85, y: 0.85)],
     platforms: [PlatformData(rect: .init(x: 0.3, y: 0.58, width: 0.4, height: 0.04))]),

    // Cross guard
    (dogs: [.init(x: 0.5, y: 0.5)],
     hives: [.init(x: 0.1, y: 0.85), .init(x: 0.9, y: 0.15), .init(x: 0.5, y: 0.9)],
     platforms: [
        PlatformData(rect: .init(x: 0.2, y: 0.36, width: 0.25, height: 0.04)),
        PlatformData(rect: .init(x: 0.55, y: 0.36, width: 0.25, height: 0.04)),
        PlatformData(rect: .init(x: 0.2, y: 0.62, width: 0.25, height: 0.04)),
        PlatformData(rect: .init(x: 0.55, y: 0.62, width: 0.25, height: 0.04))
     ])
]

private let hazardSlots: [CGPoint] = [
    .init(x: 0.2, y: 0.1), .init(x: 0.4, y: 0.1), .init(x: 0.6, y: 0.1), .init(x: 0.8, y: 0.1)
]

private let hazardCycle: [HazardType] = [.spike, .water, .bomb]

private func generateLevel(_ level: Int) -> LevelConfig {
    let tier = level - 30
    let template = levelTemplates[(level - 31) % levelTemplates.count]
    let hazardCount = min(1 + tier / 15, hazardSlots.count)
    let hazards = (0..<hazardCount).map { i in
        HazardData(position: hazardSlots[i], type: hazardCycle[(level + i) % hazardCycle.count])
    }

    return LevelConfig(
        level: level,
        dogPositions: template.dogs,
        beehivePositions: template.hives,
        platforms: template.platforms,
        hazards: hazards,
        beeCount: min(12 + tier / 3, 30),
        hasQueenBee: level % 3 == 0
    )
}

let allLevels: [LevelConfig] = handCraftedLevels + (31...100).map(generateLevel)
