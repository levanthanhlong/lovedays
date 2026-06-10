import SpriteKit

class DogNode: SKNode {
    static let radius: CGFloat = 36

    private let sprite: SKSpriteNode

    override init() {
        sprite = SKSpriteNode(imageNamed: "dog_normal")
        sprite.size = CGSize(width: 84, height: 84)
        super.init()
        addChild(sprite)

        physicsBody = SKPhysicsBody(circleOfRadius: DogNode.radius)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = PhysicsCategory.dog
        physicsBody?.contactTestBitMask = PhysicsCategory.bee
        physicsBody?.collisionBitMask = 0
    }

    required init?(coder: NSCoder) { fatalError() }

    func showStung() {
        sprite.texture = SKTexture(imageNamed: "dog_stung")
        // slight shake animation
        let shakeLeft  = SKAction.moveBy(x: -6, y: 0, duration: 0.05)
        let shakeRight = SKAction.moveBy(x: 12, y: 0, duration: 0.05)
        let center     = SKAction.moveBy(x: -6, y: 0, duration: 0.05)
        sprite.run(.sequence([shakeLeft, shakeRight, shakeLeft, shakeRight, center]))
    }
}
