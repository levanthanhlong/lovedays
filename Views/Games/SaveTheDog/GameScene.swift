import SpriteKit
import UIKit

// MARK: - Physics categories

struct PhysicsCategory {
    static let dog: UInt32    = 0x1 << 0
    static let bee: UInt32    = 0x1 << 1
    static let wall: UInt32   = 0x1 << 2
    static let ground: UInt32 = 0x1 << 3
}

// MARK: - Emoji texture helper

func emojiTexture(_ emoji: String, size: CGSize) -> SKTexture {
    let renderer = UIGraphicsImageRenderer(size: size)
    let image = renderer.image { _ in
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: size.width * 0.78)
        ]
        let str = emoji as NSString
        let textSize = str.size(withAttributes: attrs)
        let rect = CGRect(
            x: (size.width - textSize.width) / 2,
            y: (size.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )
        str.draw(in: rect, withAttributes: attrs)
    }
    return SKTexture(image: image)
}

// MARK: - Game state

enum STDGameState { case idle, drawing, countdown, won, lost }

// MARK: - Scene

class GameScene: SKScene, SKPhysicsContactDelegate {
    let config: LevelConfig
    var onStateChange: ((STDGameState) -> Void)?

    private(set) var gameState: STDGameState = .idle
    private var dogs: [DogNode] = []
    private var bees: [BeeNode] = []
    private var hivePositions: [CGPoint] = []

    private var currentDrawPath: CGMutablePath?
    private var currentDrawNode: SKShapeNode?

    private var countdownRemaining: TimeInterval = 10
    private var lastUpdateTime: TimeInterval = 0
    private var beeSpawnTimer: TimeInterval = 0
    private var beesSpawned = 0
    private var totalBeeCount: Int { max(config.beeCount + 20, 30) }

    private var countdownLabel: SKLabelNode!

    init(config: LevelConfig, size: CGSize) {
        self.config = config
        super.init(size: size)
        scaleMode = .resizeFill
    }

    required init?(coder: NSCoder) { fatalError() }

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.12, green: 0.10, blue: 0.18, alpha: 1)
        physicsWorld.gravity = CGVector(dx: 0, dy: -3)
        physicsWorld.contactDelegate = self
        addChild(makeStarfield())
        setupBoundaries()
        setupCountdownLabel()
        loadLevel()
    }

    // MARK: - Setup

    private func makeStarfield() -> SKNode {
        let node = SKNode()
        for _ in 0..<30 {
            let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 0.5...2))
            star.fillColor = .white
            star.strokeColor = .clear
            star.alpha = CGFloat.random(in: 0.2...0.5)
            star.position = CGPoint(x: CGFloat.random(in: 0...size.width),
                                    y: CGFloat.random(in: 0...size.height))
            star.zPosition = -2
            node.addChild(star)
        }
        return node
    }

    private func setupBoundaries() {
        physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(origin: .zero, size: size))
        physicsBody?.categoryBitMask = PhysicsCategory.ground
        physicsBody?.collisionBitMask = PhysicsCategory.bee | PhysicsCategory.wall
        physicsBody?.contactTestBitMask = 0

        let floorNode = SKSpriteNode(
            color: SKColor(red: 0.28, green: 0.20, blue: 0.12, alpha: 1),
            size: CGSize(width: size.width, height: size.height * 0.06)
        )
        floorNode.position = CGPoint(x: size.width / 2, y: size.height * 0.03)
        floorNode.zPosition = -1
        addChild(floorNode)
    }

    private func setupCountdownLabel() {
        countdownLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        countdownLabel.fontSize = 24
        countdownLabel.fontColor = .white
        countdownLabel.position = CGPoint(x: size.width / 2, y: size.height - 60)
        countdownLabel.zPosition = 100
        countdownLabel.text = "✏️ Vẽ tường để bảo vệ!"
        addChild(countdownLabel)
    }

    private func loadLevel() {
        hivePositions = config.beehivePositions.map { scenePoint($0) }

        for platform in config.platforms { addPlatform(platform) }
        for hazard in config.hazards { addHazard(hazard) }

        for pos in config.dogPositions {
            let dog = DogNode()
            dog.position = scenePoint(pos)
            dog.zPosition = 5
            dogs.append(dog)
            addChild(dog)
        }

        for pos in hivePositions {
            let hive = SKLabelNode(text: "🍯")
            hive.fontSize = 34
            hive.position = pos
            hive.zPosition = 3
            addChild(hive)
        }
    }

    private func addPlatform(_ data: PlatformData) {
        let w = data.rect.width * size.width
        let h = data.rect.height * size.height
        let x = data.rect.minX * size.width + w / 2
        let y = data.rect.minY * size.height + h / 2

        let node = SKSpriteNode(
            color: SKColor(red: 0.42, green: 0.28, blue: 0.14, alpha: 1),
            size: CGSize(width: w, height: h)
        )
        node.position = CGPoint(x: x, y: y)
        node.zPosition = 2
        node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: w, height: h))
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = PhysicsCategory.ground
        node.physicsBody?.collisionBitMask = PhysicsCategory.bee | PhysicsCategory.wall
        node.physicsBody?.contactTestBitMask = 0
        node.physicsBody?.friction = 0.4
        addChild(node)
    }

    private func addHazard(_ data: HazardData) {
        let label = SKLabelNode(text: data.type.rawValue)
        label.fontSize = 30
        label.position = scenePoint(data.position)
        label.zPosition = 2
        addChild(label)
    }

    private func scenePoint(_ normalized: CGPoint) -> CGPoint {
        CGPoint(x: normalized.x * size.width, y: normalized.y * size.height)
    }

    // MARK: - Drawing

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard gameState == .idle, let touch = touches.first else { return }
        let loc = touch.location(in: self)
        currentDrawPath = CGMutablePath()
        currentDrawPath?.move(to: loc)

        let node = SKShapeNode()
        node.strokeColor = SKColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 0.9)
        node.lineWidth = 7
        node.lineCap = .round
        node.lineJoin = .round
        node.zPosition = 10
        addChild(node)
        currentDrawNode = node
        gameState = .drawing
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard gameState == .drawing, let touch = touches.first else { return }
        currentDrawPath?.addLine(to: touch.location(in: self))
        currentDrawNode?.path = currentDrawPath
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard gameState == .drawing, let path = currentDrawPath, let node = currentDrawNode else { return }

        let points = samplePathPoints(path, stride: 10)
        guard points.count >= 2 else {
            node.removeFromParent()
            currentDrawNode = nil
            currentDrawPath = nil
            gameState = .idle
            return
        }

        let centroid = CGPoint(
            x: points.reduce(0) { $0 + $1.x } / CGFloat(points.count),
            y: points.reduce(0) { $0 + $1.y } / CGFloat(points.count)
        )
        let localPoints = points.map { CGPoint(x: $0.x - centroid.x, y: $0.y - centroid.y) }

        let localPath = CGMutablePath()
        localPath.move(to: localPoints[0])
        for point in localPoints.dropFirst() { localPath.addLine(to: point) }

        node.position = centroid
        node.path = localPath

        // Compound body of small circles along the path — falls with gravity
        // and hooks onto terrain (edgeChainFrom bodies are always static, so
        // a fallable wall must be built from dynamic circle sub-bodies).
        let r: CGFloat = 6
        let bodies = localPoints.map { SKPhysicsBody(circleOfRadius: r, center: $0) }
        let wallBody = SKPhysicsBody(bodies: bodies)
        wallBody.categoryBitMask = PhysicsCategory.wall
        wallBody.collisionBitMask = PhysicsCategory.bee | PhysicsCategory.ground | PhysicsCategory.wall
        wallBody.contactTestBitMask = 0
        wallBody.isDynamic = true
        wallBody.affectedByGravity = true
        wallBody.allowsRotation = true
        wallBody.angularDamping = 4.0
        wallBody.linearDamping = 0.5
        wallBody.friction = 0.9
        wallBody.restitution = 0.05
        node.physicsBody = wallBody

        currentDrawNode = nil
        currentDrawPath = nil
        startCountdown()
    }

    // Sample points along the drawn path, keeping a minimum spacing so the
    // resulting compound physics body isn't built from too many sub-bodies.
    private func samplePathPoints(_ path: CGPath, stride: CGFloat) -> [CGPoint] {
        var rawPoints: [CGPoint] = []
        path.applyWithBlock { element in
            switch element.pointee.type {
            case .moveToPoint, .addLineToPoint:
                rawPoints.append(element.pointee.points[0])
            default:
                break
            }
        }
        guard let first = rawPoints.first else { return [] }

        var sampled: [CGPoint] = [first]
        for point in rawPoints.dropFirst() {
            if let last = sampled.last, hypot(point.x - last.x, point.y - last.y) >= stride {
                sampled.append(point)
            }
        }
        if let last = rawPoints.last, sampled.last != last {
            sampled.append(last)
        }
        return sampled
    }

    // MARK: - Game loop

    private func startCountdown() {
        gameState = .countdown
        countdownRemaining = 10
        beeSpawnTimer = 0
        beesSpawned = 0
        lastUpdateTime = 0
        countdownLabel.text = "10"
    }

    override func update(_ currentTime: TimeInterval) {
        defer { lastUpdateTime = currentTime }
        guard gameState == .countdown else { return }

        let delta = lastUpdateTime > 0 ? currentTime - lastUpdateTime : 0

        beeSpawnTimer += delta
        if beesSpawned < totalBeeCount, beeSpawnTimer >= 0.22 {
            beeSpawnTimer = 0
            spawnNextBee()
        }

        for bee in bees where bee.parent != nil {
            guard let target = nearestDog(to: bee.position) else { continue }
            bee.update(deltaTime: delta, toward: target.position, separateFrom: bees)
        }

        countdownRemaining -= delta
        let secsLeft = max(0, Int(ceil(countdownRemaining)))
        countdownLabel.text = "\(secsLeft)"
        countdownLabel.fontColor = countdownRemaining <= 3 ? SKColor(red: 1, green: 0.3, blue: 0.2, alpha: 1) : .white

        if countdownRemaining <= 0 { triggerWin() }
    }

    private func spawnNextBee() {
        let isQueen = config.hasQueenBee && beesSpawned == totalBeeCount - 1
        let bee = BeeNode(isQueen: isQueen, index: beesSpawned)
        let hivePos = hivePositions[beesSpawned % hivePositions.count]
        bee.position = CGPoint(
            x: hivePos.x + CGFloat.random(in: -15...15),
            y: hivePos.y + CGFloat.random(in: -15...15)
        )
        bee.zPosition = 6
        bee.setScale(0.1)
        bee.run(.scale(to: 1.0, duration: 0.25))
        bees.append(bee)
        addChild(bee)
        beesSpawned += 1
    }

    private func nearestDog(to point: CGPoint) -> DogNode? {
        dogs.min { a, b in distance(point, a.position) < distance(point, b.position) }
    }

    private func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        sqrt(pow(b.x - a.x, 2) + pow(b.y - a.y, 2))
    }

    private func triggerWin() {
        guard gameState == .countdown else { return }
        gameState = .won
        freezeBees()
        showResultEmoji("🎉")
        onStateChange?(.won)
    }

    private func triggerLose() {
        guard gameState == .countdown else { return }
        gameState = .lost
        freezeBees()
        // swap every dog to stung image immediately
        for dog in dogs { dog.showStung() }
        // delay popup ~3.5s so the stung animation is visible
        run(.sequence([
            .wait(forDuration: 3.5),
            .run { [weak self] in self?.onStateChange?(.lost) }
        ]))
    }

    private func freezeBees() {
        for bee in bees {
            bee.physicsBody?.isDynamic = false
            bee.physicsBody?.velocity = .zero
        }
    }

    private func showResultEmoji(_ emoji: String) {
        let label = SKLabelNode(text: emoji)
        label.fontSize = 80
        label.position = CGPoint(x: size.width / 2, y: size.height / 2)
        label.zPosition = 50
        label.setScale(0.1)
        addChild(label)
        label.run(.sequence([.scale(to: 1.4, duration: 0.25), .scale(to: 1.0, duration: 0.1)]))
    }

    // MARK: - Contact delegate

    func didBegin(_ contact: SKPhysicsContact) {
        let combined = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        guard combined == (PhysicsCategory.bee | PhysicsCategory.dog) else { return }
        DispatchQueue.main.async { self.triggerLose() }
    }
}
