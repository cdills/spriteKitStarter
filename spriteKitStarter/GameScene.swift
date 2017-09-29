//
//  GameScene.swift
//  spriteKitStarter
//
//  Created by Cody on 9/28/17.
//  Copyright © 2017 DillsPC. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    //1 Declare constant sprite, pass image name
    let player = SKSpriteNode(imageNamed: "player")
    
    override func didMove(to view: SKView) {
        //2 obv
        backgroundColor = SKColor.white
        //3 sets position at 10% vertically and centered horizontally- remember we are in landscape
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        //4 draws node on screen
        addChild(player)
        
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(addMonster),
            SKAction.wait(forDuration: 1.0)
        ])))
    }

    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }

    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }

    func addMonster() {
        //Create Sprite
        let monster = SKSpriteNode(imageNamed: "monster")
        
        //determine actual spawn location on Y axis
        let actualY = random(min: monster.size.height/2, max: size.height - monster.size.height / 2)
        
        //position slightly off screen on X axis, and randomY as above
        monster.position = CGPoint(x: size.width + monster.size.width/2, y: actualY)
        
        //add to scene
        addChild(monster)
        
        //calclulate speed
        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        
        //create actions
        let actionMove = SKAction.move(to: CGPoint(x: -monster.size.width/2, y: actualY), duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        
        // Does action, sequence is list of actions
        monster.run(SKAction.sequence([actionMove, actionMoveDone]))
        
    }

}
