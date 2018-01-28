//
//  GameViewController.swift
//  CandyCrushClone
//
//  Created by Bartu Kovan on 23.01.2018.
//  Copyright © 2018 Bartu Kovan. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    var scene: GameScene!
    var level: Level!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = view as! SKView
        skView.isMultipleTouchEnabled = false
        
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        
        
        level = Level(filename: "Level_1")
        scene.level = level
        scene.addTiles()
        
        scene.swipeHandler = handleSwipe 
        skView.presentScene(scene)
        
        beginGame()
    }
    //Cookieleri karma için kullanacağımız fonksiyon
    func beginGame() {
        shuffle()
    }
    
    func shuffle() {
        let newCookies = level.shuffle()
        scene.addSprites(for: newCookies)
    }
    
    func handleSwipe(_ swap: Swap) {
        view.isUserInteractionEnabled = false
        
        if level.isPossibleSwap(swap) {
            level.performSwap(swap: swap)
            scene.animate(swap, completion: {
                self.view.isUserInteractionEnabled = true
            })
        } else {
            scene.animateInvalidSwap(swap, completion: {
                self.view.isUserInteractionEnabled = true
            })
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
