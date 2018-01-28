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
    
    //Bu fonksiyonu yazmamızın sebebi bir chain oluşturduktan sonra gelen yeni cookielerinde bir chain oluşturması durumunda
    //Bunlarında otomatik olarak match olmasını sağlamak
    //level.detectPossibleSwaps -> Bir süre oynadıktan sonra yeni cookieler gelip yeni chain ihtimalleri olmasına rağmen
    //biz bunu hesaplatmadığımız için oynamamıza izin vermiyor
    //her yeni cookie gelişinden sonra bunu tekrar kullanıyoruz ki sonsuz bi döndü yaratalım (en azından oyun bitene kadar)
    func beginNextTurn() {
        level.detectPossibleSwaps()
        view.isUserInteractionEnabled = true
    }
    
    //Match fonksiyonumuz
    //isUserInteraction ı sona yazmamız player animasyon bitmeden başka match yapmasın diye
    func handleMatches() {
        let chains = level.removeMatches()
        if chains.count == 0 {
            beginNextTurn()
            return
        }
        scene.animateMatchedCookies(for: chains) {
            let columns = self.level.fillHoles()
            self.scene.animateFallingCookies(columns: columns, completion: {
                let columns = self.level.topUpCookies()
                self.scene.animateNewCookies(columns, completion: {
                    self.handleMatches()
                })
            })
        }
    }
    
    func handleSwipe(_ swap: Swap) {
        view.isUserInteractionEnabled = false
        
        if level.isPossibleSwap(swap) {
            level.performSwap(swap: swap)
            scene.animate(swap, completion: handleMatches)
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
