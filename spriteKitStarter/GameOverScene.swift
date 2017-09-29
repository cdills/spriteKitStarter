//
//  GameOverScene.swift
//  spriteKitStarter
//
//  Created by Cody on 9/29/17.
//  Copyright © 2017 DillsPC. All rights reserved.
//

import Foundation
import SpriteKit


class GameOverScene: SKScene {
    
    init(size: CGSize, won:Bool) {
        
        super.init(size: size)
        backgroundColor = SKColor.white
        let message = won ? "You Won!" : "You Lose :["
        
        //label is another SKNode so we can use addChild
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = message
        label.fontSize = 40
        label.fontColor = SKColor.black
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
        
        //wait 3 seconds and then use .run() to run whatever code we need. scene transition in this case
        run(SKAction.sequence([
            SKAction.wait(forDuration: 3.0),
            SKAction.run() {
                // can choose from animations in sktransition. Then create constant for scene we want, and present
                let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                let scene = GameScene(size: size)
                self.view?.presentScene(scene, transition:reveal)
            }
            ]))
        
    }
    
    //I dont quite understand what the coder: does but it is not in use anyway. 
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
