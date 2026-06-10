import SpriteKit

class BeeNode: SKNode {
    let isQueen: Bool
    let beeSpeed: CGFloat

    private let approachAngleOffset: CGFloat
    private var stuckTimer: TimeInterval = 0
    private var prevPosition: CGPoint = .zero

    init(isQueen: Bool = false, index: Int = 0) {
        self.isQueen = isQueen
        self.beeSpeed = isQueen ? 160 : 240
        // Spread bees across ±70° so none start flying away from dog
        let spread: CGFloat = CGFloat.pi * 7 / 18
        self.approachAngleOffset = (CGFloat(index % 30) / 29.0 - 0.5) * spread
        super.init()

        let px: CGFloat = isQueen ? 52 : 32
        let sprite = SKSpriteNode(texture: emojiTexture("🐝", size: CGSize(width: px, height: px)))
        if isQueen {
            sprite.color = SKColor(red: 1, green: 0.7, blue: 0, alpha: 1)
            sprite.colorBlendFactor = 0.4
        }
        addChild(sprite)

        let r: CGFloat = isQueen ? 22 : 14
        physicsBody = SKPhysicsBody(circleOfRadius: r)
        physicsBody?.categoryBitMask = PhysicsCategory.bee
        physicsBody?.contactTestBitMask = PhysicsCategory.dog
        physicsBody?.collisionBitMask = PhysicsCategory.wall | PhysicsCategory.ground
        physicsBody?.allowsRotation = false
        physicsBody?.linearDamping = 1.5
        physicsBody?.mass = isQueen ? 3.0 : 1.0
        physicsBody?.usesPreciseCollisionDetection = true
    }

    required init?(coder: NSCoder) { fatalError() }

    // No avoidance param — bees deflect off walls naturally via physics (applyForce steering)
    func update(deltaTime: TimeInterval, toward target: CGPoint, separateFrom others: [BeeNode]) {
        guard let body = physicsBody else { return }

        let dx = target.x - position.x
        let dy = target.y - position.y
        let dist = hypot(dx, dy)

        // stuck detection — burst to escape tight corners
        let moved = hypot(position.x - prevPosition.x, position.y - prevPosition.y)
        stuckTimer = moved < 3 ? stuckTimer + deltaTime : 0
        prevPosition = position

        var desiredVx: CGFloat = 0
        var desiredVy: CGFloat = 0

        if dist > 5 {
            let angle = atan2(dy, dx) + approachAngleOffset
            desiredVx = cos(angle) * beeSpeed
            desiredVy = sin(angle) * beeSpeed
        }

        // last-resort burst when stuck >1s
        if stuckTimer > 1.0 {
            let burst = CGFloat.random(in: 0...(CGFloat.pi * 2))
            desiredVx += cos(burst) * beeSpeed * 1.2
            desiredVy += sin(burst) * beeSpeed * 1.2
        }

        // separation — prevent bee pileups
        for other in others where other !== self {
            let sx = position.x - other.position.x
            let sy = position.y - other.position.y
            let sd = hypot(sx, sy)
            if sd < 30, sd > 0 {
                desiredVx += sx / sd * 70
                desiredVy += sy / sd * 70
            }
        }

        // applyForce (not velocity override) — preserves physics collision response
        // bees redirect ON CONTACT with walls, not before
        let current = body.velocity
        let responsiveness: CGFloat = body.mass * 7
        body.applyForce(CGVector(
            dx: (desiredVx - current.dx) * responsiveness,
            dy: (desiredVy - current.dy) * responsiveness
        ))

        // cap max speed
        let v = body.velocity
        let spd = hypot(v.dx, v.dy)
        let maxSpd = beeSpeed * 1.5
        if spd > maxSpd {
            body.velocity = CGVector(dx: v.dx / spd * maxSpd, dy: v.dy / spd * maxSpd)
        }
    }
}
