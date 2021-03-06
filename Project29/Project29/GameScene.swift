//
//  GameScene.swift
//  Project29
//
//  Created by Jeffrey Eng on 9/16/16.
//  Copyright (c) 2016 Jeffrey Eng. All rights reserved.
//

import SpriteKit

enum CollisionTypes: UInt32 {
    case banana = 1
    case building = 2
    case player = 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    weak var viewController: GameViewController!
    
    var buildings = [BuildingNode]()
    var player1: SKSpriteNode!
    var player2: SKSpriteNode!
    var banana: SKSpriteNode!
    
    var currentPlayer = 1
    
    override func didMoveToView(view: SKView) {
        // Set the background color of the scene to a dark blue color (for the night sky)
        backgroundColor = UIColor(hue: 0.669, saturation: 0.99, brightness: 0.67, alpha: 1)
        
        createBuildings()
        createPlayers()
        
        // assign 'self' to be delegate of scene's physics world so we get notified of collisions
        physicsWorld.contactDelegate = self
    }
    
    func createBuildings() {
        // start off the sceeen to the left
        var currentX: CGFloat = -15
        
        while currentX < 1024 {
            let size = CGSize(width: RandomInt(min: 2, max: 4) * 40, height: RandomInt(min: 300, max: 600))
            currentX += size.width + 2
            
            // Create instances of the building objects, position it, call setup(give it name, physics, texture), and add the building node to the scene
            let building = BuildingNode(color: UIColor.redColor(), size: size)
            building.position = CGPoint(x: currentX - (size.width / 2), y: size.height / 2)
            building.setup()
            addChild(building)
            
            // Store each instance of the building node in the array
            buildings.append(building)
        }
    }
    
    func createPlayers() {
        player1 = SKSpriteNode(imageNamed: "player")
        player1.name = "player1"
        player1.physicsBody = SKPhysicsBody(circleOfRadius: player1.size.width / 2)
        player1.physicsBody!.categoryBitMask = CollisionTypes.player.rawValue
        player1.physicsBody!.collisionBitMask = CollisionTypes.banana.rawValue
        player1.physicsBody!.contactTestBitMask = CollisionTypes.banana.rawValue
        player1.physicsBody!.dynamic = false
        
        let player1Building = buildings[1]
        // Positions player at the top of the building
        player1.position = CGPoint(x: player1Building.position.x, y: player1Building.position.y + ((player1Building.size.height + player1.size.height) / 2))
        addChild(player1)
        
        
        player2 = SKSpriteNode(imageNamed: "player")
        player2.name = "player2"
        player2.physicsBody = SKPhysicsBody(circleOfRadius: player2.size.width / 2)
        player2.physicsBody!.categoryBitMask = CollisionTypes.player.rawValue
        player2.physicsBody!.collisionBitMask = CollisionTypes.banana.rawValue
        player2.physicsBody!.contactTestBitMask = CollisionTypes.banana.rawValue
        player2.physicsBody!.dynamic = false
        
        let player2Building = buildings[buildings.count - 2]
        player2.position = CGPoint(x: player2Building.position.x, y: player2Building.position.y + ((player2Building.size.height + player2.size.height) / 2))
        addChild(player2)
    }
    
    func degreeToRadian(degrees: Int) -> Double {
        return Double(degrees) * M_PI / 180.0
    }
    
    func launch(angle angle: Int, velocity: Int) {
        // 1) Figure out how hard to throw the banana. We accept a velocity parameter, but I'll be dividing that by 10. You can adjust this based on your own play testing.
        let speed = Double(velocity) / 10.0
        
        // 2) Convert the input angle to radians.  Most people don't think in radians, so the input will come in as degrees that we convert to radians.
        let radians = degreeToRadian(angle)
        
        // 3) If somehow there's a banana already, we'll remove it then create a new one using circle physics.
        if banana != nil {
            banana.removeFromParent()
            banana = nil
        }
        
        banana = SKSpriteNode(imageNamed: "banana")
        banana.name = "banana"
        banana.physicsBody = SKPhysicsBody(circleOfRadius: banana.size.width / 2)
        banana.physicsBody!.categoryBitMask = CollisionTypes.banana.rawValue
        banana.physicsBody!.collisionBitMask = CollisionTypes.building.rawValue | CollisionTypes.player.rawValue
        banana.physicsBody!.contactTestBitMask = CollisionTypes.building.rawValue | CollisionTypes.player.rawValue
        banana.physicsBody!.usesPreciseCollisionDetection = true
        addChild(banana)
        
        // 4) If player 1 was throwing the banana, we position it up and to the left of the player and give it some spin.
        if currentPlayer == 1 {
            banana.position = CGPoint(x: player1.position.x - 30, y: player1.position.y + 40)
            banana.physicsBody!.angularVelocity = -20
            
            // 5) Animate player 1 throwing their arm up then putting it down again using a sequence
            let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player1Throw"))
            let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
            let pause = SKAction.waitForDuration(0.15)
            let sequence = SKAction.sequence([raiseArm, lowerArm, pause])
            player1.runAction(sequence)
            
            // 6) Make the banana move in the correct direction.
            let impulse = CGVector(dx: cos(radians) * speed, dy: sin(radians) * speed)
            banana.physicsBody?.applyImpulse(impulse)
        } else {
            // 7) If player 2 was throwing the banana, we position it up and to the right, apply the opposite spin, then make it move in the correct direction.
            banana.position = CGPoint(x: player2.position.x + 30, y: player2.position.y + 40)
            banana.physicsBody!.angularVelocity = 20
            
            let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player2Throw"))
            let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
            let pause = SKAction.waitForDuration(0.15)
            let sequence = SKAction.sequence([raiseArm, lowerArm, pause])
            player2.runAction(sequence)
            
            let impulse = CGVector(dx: cos(radians) * -speed, dy: sin(radians) * speed)
            banana.physicsBody?.applyImpulse(impulse)
        }
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if let firstNode = firstBody.node {
            if let secondNode = secondBody.node {
                if firstNode.name == "banana" && secondNode.name == "building" {
                    bananaHit(building: secondNode as! BuildingNode, atPoint: contact.contactPoint)
                }
                
                if firstNode.name == "banana" && secondNode == "player1" {
                    destroy(player1)
                }
                
                if firstNode.name == "banana" && secondNode == "player2" {
                    destroy(player2)
                }
            }
        }
    }
    
    func destroy(player: SKSpriteNode) {
        // Create the SpriteKit explosion animation
        let explosion = SKEmitterNode(fileNamed: "hitPlayer")!
        explosion.position = player.position
        addChild(explosion)
        
        // Remove the player and banana from the scene when banana hits the player
        player.removeFromParent()
        banana?.removeFromParent()
        
        RunAfterDelay(2) { [unowned self] in
            
            // Transitions to a new Game Scene
            let newGame = GameScene(size: self.size)
            newGame.viewController = self.viewController
            self.viewController.currentGame = newGame
            
            // Calls changePlayer method when player is destroyed
            self.changePlayer()
            // Transfers control of the game to the other player
            newGame.currentPlayer = self.currentPlayer
            
            // Create smooth transition to the next game
            let transition = SKTransition.doorwayWithDuration(1.5)
            self.view?.presentScene(newGame, transition: transition)
        }
    }
    
    func changePlayer() {
        // Set new game's currentPlayer property to our own currentPlayer property so whoever died gets the first shot
        if currentPlayer == 1 {
            currentPlayer = 2
        } else {
            currentPlayer = 1
        }
        
        viewController.activatePlayer(currentPlayer)
    }
    
    // Method that handles creating explosion, deleting the banana and changing players
    func bananaHit(building building: BuildingNode, atPoint contactPoint: CGPoint) {
        // Convert collision contact point into coordinates relative to the building node
        let buildingLocation = convertPoint(contactPoint, toNode: building)
        building.hitAtPoint(buildingLocation)
        
        // create explosion
        let explosion = SKEmitterNode(fileNamed: "hitBuilding")!
        explosion.position = contactPoint
        addChild(explosion)
        
        // delete banana
        // the name property is set to empty string to remove possibility of second collision if banana hits two buildings simultaneously
        banana.name = ""
        banana?.removeFromParent()
        banana = nil
        
        // change players
        changePlayer()
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {

    }
   
    override func update(currentTime: CFTimeInterval) {
        // Handling scenario where banana doesn't hit a building or player and goes off screen, which normally would stall the game.
        if banana != nil {
            if banana.position.y < -1000 {
                banana.removeFromParent()
                banana = nil
                
                changePlayer()
            }
        }
    }
}
