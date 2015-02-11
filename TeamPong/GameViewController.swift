
import SpriteKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = GameScene(size: view.bounds.size)
        let skVeiw = view as SKView
        skVeiw.showsFPS = true
        skVeiw.showsNodeCount = true
        skVeiw.ignoresSiblingOrder = true
        scene.scaleMode = .ResizeFill
        skVeiw.presentScene(scene)
        scene.addObserver(self, forKeyPath: "score", options: nil, context: nil)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if keyPath == "score"{
            println("score changed")
        }
    }
}
