//
//  GameViewController.swift
//  Project29
//
//  Created by Jeffrey Eng on 9/16/16.
//  Copyright (c) 2016 Jeffrey Eng. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    var currentGame: GameScene!
    
    @IBOutlet weak var angleSlider: UISlider!
    @IBOutlet weak var angleLabel: UILabel!
    @IBOutlet weak var velocitySlider: UISlider!
    @IBOutlet weak var velocityLabel: UILabel!
    @IBOutlet weak var launchButton: UIButton!
    @IBOutlet weak var playerNumber: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Calling these methods on initial loading of app to display their default values
        angleChanged(angleSlider)
        velocityChanged(velocitySlider)
        
        if let scene = GameScene(fileNamed:"GameScene") {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            skView.presentScene(scene)
            
            // sets the currentGame property to the initial game scene; get direct access to the Game Scene whenever we need it
            currentGame = scene
            // makes sure the scene knows about the view controller
            currentGame.viewController = self
        }
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // Changing slider will change the angle label text to the current value of the slider
    @IBAction func angleChanged(sender: AnyObject) {
        angleLabel.text = "Angle: \(Int(angleSlider.value))°"
    }
    
    // Changing slider will change the velocity label text to the current value of the slider
    @IBAction func velocityChanged(sender: AnyObject) {
        velocityLabel.text = "Velocity: \(Int(velocitySlider.value))"
    }
    
    @IBAction func launch(sender: AnyObject) {
        // Need to hide the user interface after player taps launch button so they can't fire again until ready. Also need to tell game scene to launch banana using current angle and velocity
        
        angleSlider.hidden = true
        angleLabel.hidden = true
        
        velocitySlider.hidden = true
        velocityLabel.hidden = true
        
        launchButton.hidden = true
        
        currentGame.launch(angle: Int(angleSlider.value), velocity: Int(velocitySlider.value))
        
    }
    
    // Update the interface to display who's turn it is, and then re-display the controls
    func activatePlayer(number: Int) {
        if number == 1 {
            playerNumber.text = "<<< PLAYER ONE"
        } else {
            playerNumber.text = "PLAYER TWO >>>"
        }
        
        //Unhide the user interface controls and labels for next player's turn
        angleSlider.hidden = false
        angleLabel.hidden = false
        
        velocitySlider.hidden = false
        velocityLabel.hidden = false
        
        launchButton.hidden = false
    }
}
