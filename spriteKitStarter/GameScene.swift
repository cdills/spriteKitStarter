//
//  GameScene.swift
//  spriteKitStarter
//
//  Created by Cody on 9/28/17.
//  Copyright © 2017 DillsPC. All rights reserved.
//

import SpriteKit
import GameplayKit

// SpriteKite Category is a 32 bit integer. Each of the bits represents a single category allowing for 32 total
// This struct sets first bit to "Monster" and second bit to "projectile"
////Do All and None count towards the 32 cap? How can I exceed the limit in one scene?
struct PhysicsCategory {
    static let None : UInt32 = 0
    static let All  : UInt32 = UInt32.max
    static let Monster : UInt32 = 0b1
    static let Projectile : UInt32 = 0b10
}


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

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //1 Declare constant sprite, pass image name
    let player = SKSpriteNode(imageNamed: "player")
    
    override func didMove(to view: SKView) {
        //2 sets background Color
        backgroundColor = SKColor.white
        //3 sets position at 10% vertically and centered horizontally- remember we are in landscape
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        //4 draws node on screen
        addChild(player)
        
        physicsWorld.gravity = CGVector.zero //Sets our "PHYSICS WORLD" to be gravity free
        physicsWorld.contactDelegate = self // sets the scene as deleegate to be notified when contact is made between bodies
        
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(addMonster),
            SKAction.wait(forDuration: 1.0)
        ])))
        
        //Adds some backgrund music. just like adding a sprte, addchild with SK_Node
        let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)
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
        //Do physics
        monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size) //Physicsbody = hitbox. uses rectangle here to approximate. SUPER USEFUL
        monster.physicsBody?.isDynamic = true //this means physics engine WILL NOT contol the movement. we will control it via move actions
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster //sets category
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile //chooses categories of objects this objects should send contact notifications for to delegate. it "test" for Contact
        monster.physicsBody?.collisionBitMask = PhysicsCategory.None //which objects should this object collide with / Physics controlled collisions (bouncing) / Set to none so they passthrough
        
        
        //calclulate speed
        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        
        //create actions
        let actionMove = SKAction.move(to: CGPoint(x: -monster.size.width/2, y: actualY), duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        
        // Does action, sequence is list of actions
        monster.run(SKAction.sequence([actionMove, actionMoveDone]))
        
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //playsound effect on touchend
        run(SKAction.playSoundFileNamed("pew-pew-lei", waitForCompletion: false))
        
        // Choose a touch to work with
        // Returns if there is no touch?
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in:self)
        
        // Set initial location of projection
        let projectile = SKSpriteNode(imageNamed: "projectile") //Reminder: this creates a sprite constant with the image specified
        projectile.position = player.position //because we want to shoot from the player
        
        //do physics for projectile now
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2) //set hitbox to approximate circle.
        projectile.physicsBody?.isDynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
        projectile.physicsBody?.usesPreciseCollisionDetection = true //Set on fast moving bodies to make sure it happens. Why not always set? Precise is Nice
        
        
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
        
    func projectileDidCollideWithMonster(projectile: SKSpriteNode, monster: SKSpriteNode) {
        print("GET EEEEM")
        projectile.removeFromParent()
        monster.removeFromParent()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        //this part sorts the colliding bodies by their order in the category list. This should simplify calculations if categories ordered properly
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        //first uses bitwise & operator to check if the bodies are monster and projectile. If the & function returns 0 then BodycategoryBitMask does not match physicsCategory
        if ((firstBody.categoryBitMask & PhysicsCategory.Monster != 0 ) &&
            (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)) {
            //this part creates skspritenode constants to pass to our did collide function
          if let monster = firstBody.node as? SKSpriteNode,
             let projectile = secondBody.node as? SKSpriteNode {
             projectileDidCollideWithMonster(projectile: projectile, monster: monster)
            }
            
        }
        
        
        }
    
}
