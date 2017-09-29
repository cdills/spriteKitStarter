//
//  GameScene.swift
//  spriteKitStarter
//
//  Created by Cody on 9/28/17.
//  Copyright © 2017 DillsPC. All rights reserved.
//

import SpriteKit
import GameplayKit

// Pre-Built Vector Math Functions
// I should learn just what this "Vector Math" is anyway

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

class GameScene: SKScene {
    
    //1 Declare constant sprite, pass image name
    let player = SKSpriteNode(imageNamed: "player")
    
    override func didMove(to view: SKView) {
        //2 sets background Color
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

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Choose a touch to work with
        // Returns if there is no touch?
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in:self)
        
        // Set initial location of projection
        let projectile = SKSpriteNode(imageNamed: "projectile") //Reminder: this creates a sprite constant with the image specified
        projectile.position = player.position //because we want to shoot from the player
        
        //Determine offset for projectile
        let offset = touchLocation - projectile.position
        
        //quit if touchlocation is behind  or parallel to player
        if (offset.x < 0) {
            return
        }
        
        //add our sprite to screen now that we know its not shooting backwards
        addChild(projectile)
        
        //determine direction to shoot projectile. normalized() converts a point coordinate into a V E C T O R
        let direction = offset.normalized()
        
        //make is shoot far enough to be offsreen with big numbers
        let shootAmount = direction * 1000
        
        //add shoot amount to current projectile position / Remember projectile hasn't moved yet
        let realDest = shootAmount + projectile.position
        
        //create action functions using calculations from above
        let actionMove = SKAction.move(to: realDest, duration: 2.0) //speed up by decreasing duration
        let actionMoveDone = SKAction.removeFromParent() //This un-draws the sprite. Calling it after actionMove ensures the sprite is offscreen before we delete it.
        projectile.run(SKAction.sequence([actionMove, actionMoveDone]))
        
        
    }
        
        
    
    
    
    
}
