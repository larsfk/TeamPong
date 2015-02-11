
import SpriteKit
import UIKit

struct PhysicsCategory {
    static let None         : UInt32 = 0
    static let All          : UInt32 = UInt32.max
    static let Ball         : UInt32 = 0x1 << 1
    static let TopWall      : UInt32 = 0x1 << 2
    static let ButtomWall   : UInt32 = 0x1 << 3
    static let TopPad       : UInt32 = 0x1 << 4
    static let ButtomPad    : UInt32 = 0x1 << 5
}

class PlayerNode: SKSpriteNode {
    var moveableByUser = true   // Node can be moved by a user
    var life = 3                // Starting with a number of lifes
    var label = SKLabelNode()   // Label for displaying lifes
    func updateLife() {         // Updates the life
        self.life -= 1
        self.label.text = String(self.life)
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let player1 = PlayerNode(imageNamed: "player-pong.png")
    let player2 = PlayerNode(imageNamed: "player-pong.png")
    let ball = SKSpriteNode(imageNamed: "Pong-ball")
    var speedTimer = NSTimer()
    var gameoverLabel = SKLabelNode()
    var scoreLabel = SKLabelNode()
    
    // Listener to score
    var score: Int = 0{
        willSet(newScore){
            // På vei til å endres
            scoreLabel.text = "Score: \(newScore)"
        }didSet{
            // Verdi er endret
            
        }
    }
    
    override func didMoveToView(view: SKView) {
        /* Scene setup */
        let background = SKSpriteNode(imageNamed: "pong-background.png")
        background.position = CGPointMake(self.size.width / 2, self.size.height / 2)
        addChild(background)
        // Physics
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: view.frame)
        self.physicsBody?.friction = 0.0
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        // Contact
        self.physicsWorld.contactDelegate = self
        
        
        /* Player 1 - Buttom bar / home */
        player1.name = "moveableByUser"
        player1.setScale(1)
        player1.position = CGPoint(x: size.width/2, y: size.height*0.05)
        addChild(player1)
        // Physics
        player1.physicsBody = SKPhysicsBody(rectangleOfSize: player1.size)
        player1.physicsBody?.dynamic = false
        player1.physicsBody?.friction = 0.0
        player1.physicsBody?.restitution = 1.0
        // Contact
        player1.physicsBody!.categoryBitMask = PhysicsCategory.ButtomPad
        player1.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        
        
        /* Player 2 - Top bar / opponent */
        player2.name = "moveableByUser"
        player2.setScale(1)
        player2.position = CGPoint(x: size.width/2, y: size.height*0.95)
        addChild(player2)
        // Physics
        player2.physicsBody = SKPhysicsBody(rectangleOfSize: player1.size)
        player2.physicsBody?.dynamic = false
        player2.physicsBody?.friction = 0.0
        player2.physicsBody?.restitution = 1.0
        // Contact
        player2.physicsBody!.categoryBitMask = PhysicsCategory.TopPad
        player2.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        
        
        /* Ball */
        ball.setScale(0.5)
        ball.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(ball)
        // Physics
        ball.physicsBody = SKPhysicsBody(rectangleOfSize: ball.size)
        ball.physicsBody?.friction = 0.0
        ball.physicsBody?.restitution = 1.0
        ball.physicsBody?.linearDamping = 0.0
        ball.physicsBody?.angularDamping = 0.0
        ball.physicsBody?.allowsRotation = false
        // Contact
        ball.physicsBody!.categoryBitMask = PhysicsCategory.Ball
        
        
        
        /* Buttom */
        let buttomRect = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 1)
        let buttom = SKNode()
        addChild(buttom)
        // Physics
        buttom.physicsBody = SKPhysicsBody(edgeLoopFromRect: buttomRect)
        // Contact
        buttom.physicsBody!.categoryBitMask = PhysicsCategory.ButtomWall
        buttom.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        
        
        /* Top */
        let topRect = CGRectMake(frame.origin.x, frame.size.height, frame.size.width, 1)
        let top = SKNode()
        addChild(top)
        // Physics
        top.physicsBody = SKPhysicsBody(edgeLoopFromRect: topRect)
        // Contact
        top.physicsBody!.categoryBitMask = PhysicsCategory.TopWall
        top.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        
        /* Life-label player 1 */
        player1.label.text = String(player1.life)
        player1.label.fontColor = SKColor.whiteColor()
        player1.label.fontName = "Helvetica-bold"
        player1.label.zRotation = CGFloat(3*M_PI/2)
        player1.label.position = CGPoint(x: size.width*0.9, y: size.height*0.45)
        addChild(player1.label)
        
        /* Life-label player 2 */
        player2.label.text = String(player2.life)
        player2.label.fontColor = SKColor.whiteColor()
        player2.label.fontName = "Helvetica-bold"
        player2.label.zRotation = CGFloat(3*M_PI/2)
        player2.label.position = CGPoint(x: size.width*0.9, y: size.height*0.55)
        addChild(player2.label)
        
        /* GameOver Label */
        gameoverLabel.text = "Game over!"
        gameoverLabel.fontColor = SKColor.whiteColor()
        gameoverLabel.fontName = "Helvetica-bold"
        gameoverLabel.position = CGPoint(x: size.width/2, y: size.height/2)
        gameoverLabel.hidden = true
        addChild(gameoverLabel)
        
        /* Score Label */
        scoreLabel.text = "Score: \(score)"
        scoreLabel.fontColor = SKColor.whiteColor()
        scoreLabel.fontName = "Helvetica-bold"
        scoreLabel.position = CGPoint(x: 50, y: size.height * 0.52)
        scoreLabel.setScale(0.5)
        addChild(scoreLabel)
        
        /* Start Game */
        self.checkScore()
    }
    
    
    /* Dictonary for determing which node is selected */
    var selectedNodes:[UITouch:SKSpriteNode] = [UITouch:SKSpriteNode]()
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        for touch:AnyObject in touches {
            let location = touch.locationInNode(self)
            let node:PlayerNode? = self.nodeAtPoint(location) as? PlayerNode
            // Add the selected node to dictionary "selectedNodes"
            if (node?.moveableByUser == true) {
                let touchObj = touch as UITouch
                selectedNodes[touchObj] = node!
            }
        }
    }
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        for touch:AnyObject in touches {
            let xLocation = touch.locationInNode(self).x
            let touchObj = touch as UITouch
            // Update position of sprites
            if let node:SKSpriteNode? = selectedNodes[touchObj] {
                node?.runAction(SKAction.moveToX(xLocation, duration: 0))
            }
        }
    }
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        for touch:AnyObject in touches {
            let touchObj = touch as UITouch
            // Remove selected node from dictionary "selectedNodes"
            if let exists:AnyObject? = selectedNodes[touchObj] {
                selectedNodes[touchObj] = nil
            }
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) { // BUG! When the ball reaches high velocity (speed) this method is called multiple times, withdrawing lifes from the players.
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // Ball hits bottom - player 1 looses life
        if firstBody.categoryBitMask == PhysicsCategory.Ball && secondBody.categoryBitMask == PhysicsCategory.ButtomWall {
            println("Hit BOTTOM")
            player1.updateLife()
            self.checkScore()
        }
        // Ball hits top - player 2 looses life
        if firstBody.categoryBitMask == PhysicsCategory.Ball && secondBody.categoryBitMask == PhysicsCategory.TopWall {
            println("Hit TOP")
            player2.updateLife()
            self.checkScore()
        }
        // Ball hits TopPad - score increase
        if firstBody.categoryBitMask == PhysicsCategory.Ball && secondBody.categoryBitMask == PhysicsCategory.TopPad {
            score++
            println(score)
            println("Hit TopPad")
        }
        
        // Ball hits ButtomPad - score increase
        if firstBody.categoryBitMask == PhysicsCategory.Ball && secondBody.categoryBitMask == PhysicsCategory.ButtomPad {
            score++
            println(score)
            println("Hit ButtomPad")
        }
        
    }
    
    
    func checkScore() {
        ball.physicsBody?.velocity = CGVectorMake(0,0) // freeze the ball
        ball.runAction(SKAction .moveTo(CGPoint(x: size.width/2, y: size.height/2), duration: 0)) // move the ball to center screen
        if(player1.life <= 0 || player2.life <= 0) {
            // Fixed -1 fail
            if(player1.life < 0){
                player1.life = 0
            }else{
                player2.life = 0
            }
            
            // Game Over
            ball.removeFromParent()
            gameoverLabel.hidden = false
        } else {
            // Resets score
            score = 0
            countDown()
        }
    }
    
    func startBall() {
        let x = random(min: CGFloat(-1), max: CGFloat(2))
        let y = random(min: CGFloat(-1), max: CGFloat(2))
        println(x,y)
        ball.physicsBody?.applyImpulse(CGVectorMake(x, y))
        // Increase the speed every 10 second, until a player looses a life
        speedTimer = NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: Selector("speedUp"), userInfo: nil, repeats: true)
    }
    
    func countDown(){
        // Setting the delay time 3secs.
        let delay = 3 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            // Start game
            self.startBall()
        }
    }
    
    func speedUp() {
        /* X-direction */
        if(ball.physicsBody?.velocity.dx > 0) {
            ball.physicsBody?.velocity.dx += 50
        } else {
            ball.physicsBody?.velocity.dx -= 50
        }
        /* Y-direction */
        if(ball.physicsBody?.velocity.dy > 0) {
            ball.physicsBody?.velocity.dy += 50
        } else {
            ball.physicsBody?.velocity.dy -= 50
        }
    }
    
    func random(#min: CGFloat, max: CGFloat) -> CGFloat {
        let rand = CGFloat(Float(arc4random()) / 0xFFFFFFFF)
        return rand * (max - min) + min
    }
    
    
}