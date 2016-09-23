//
//  BuildingNode.swift
//  Project29
//
//  Created by Jeffrey Eng on 9/16/16.
//  Copyright © 2016 Jeffrey Eng. All rights reserved.
//

import GameplayKit
import SpriteKit
import UIKit

class BuildingNode: SKSpriteNode {
    // Declaring this property to keep track of what building looks like after explosions
    var currentImage: UIImage!
    
    // basic setup including setting name, texture, and physics
    func setup() {
        name = "building"
        
        // drawBuilding() returns a UIImage
        currentImage = drawBuilding(size)
        // convert the UIImage into a texture
        texture = SKTexture(image: currentImage)
        
        configurePhysics()
    }
    
    // This method is called everytime the building is hit; Sets up per-pixel physics for the sprite's current texture
    func configurePhysics() {
        physicsBody = SKPhysicsBody(texture: texture!, size: size)
        physicsBody!.dynamic = false
        physicsBody!.categoryBitMask = CollisionTypes.building.rawValue
        physicsBody!.contactTestBitMask = CollisionTypes.banana.rawValue
    }
    
    // This method does the Core Graphics rendering of a building and returns a UIImage that's being saved to the currentImage property
    func drawBuilding(size: CGSize) -> UIImage {
        // 1) Create a new Core Graphics context the size of our building
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        // 2) Fill it with a rectangle that's one of three colors
        let rectangle = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        var color: UIColor
        
        // Random color selection for the building
        switch GKRandomSource.sharedRandom().nextIntWithUpperBound(3) {
        case 0:
            color = UIColor(hue: 0.502, saturation: 0.98, brightness: 0.67, alpha: 1)
        case 1:
            color = UIColor(hue: 0.999, saturation: 0.99, brightness: 0.67, alpha: 1)
        default:
            color = UIColor(hue: 0, saturation: 0, brightness: 0.67, alpha: 1)
        }
        
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextAddRect(context, rectangle)
        CGContextDrawPath(context, .Fill)
        
        // 3) Draw windows all over the building in one of two colors: there's either a light on (yellow) or not (gray)
        let lightOnColor = UIColor(hue: 0.190, saturation: 0.67, brightness: 0.99, alpha: 1)
        let lightOffColor = UIColor(hue: 0, saturation: 0, brightness: 0.34, alpha: 1)
        
        for row in 10.stride(to: Int(size.height - 10), by: 40) {
            for col in 10.stride(to: Int(size.width - 10), by: 40) {
                if RandomInt(min: 0, max: 1) == 0 {
                    CGContextSetFillColorWithColor(context, lightOnColor.CGColor)
                } else {
                    CGContextSetFillColorWithColor(context, lightOffColor.CGColor)
                }
                
                CGContextFillRect(context, CGRect(x: col, y: row, width: 15, height: 20))
            }
        }
        // 4) Pull out the result as a UIImage and return it for use elsewhere
        let img = UIGraphicsGetImageFromCurrentImageContext()
        // Ending the image context frees up the RAM
        UIGraphicsEndImageContext()
        
        return img
    }
    
    func hitAtPoint(point: CGPoint) {
        // Get coordinates for where the building was hit
        let convertedPoint = CGPoint(x: point.x + size.width / 2.0, y: abs(point.y - (size.height / 2.0)))
        
        // Create a new Core Graphics context the size of our current sprite
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        // Draw our current building image into the context
        currentImage.drawAtPoint(CGPoint(x: 0, y: 0))
        
        // Create an ellipse at the collision point
        CGContextAddEllipseInRect(context, CGRect(x: convertedPoint.x - 32, y: convertedPoint.y - 32, width: 64, height: 64))
        CGContextSetBlendMode(context, .Clear)
        // Draws the ellipse which literally cuts an ellipse out of our image
        CGContextDrawPath(context, .Fill)
        
        // Convert contents of Core Graphics context back to a UIImage
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        // Update the building texture to the current image
        texture = SKTexture(image: img)
        // Save the UIImage to the current image property for the next time we're hit
        currentImage = img

        // Call configurePhysics() again so SpriteKit will recalculate the per-pixel physics for our damaged building
        configurePhysics()
    }
}
