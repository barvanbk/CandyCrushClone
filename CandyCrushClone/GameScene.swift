//
//  GameScene.swift
//  CandyCrushClone
//
//  Created by Bartu Kovan on 23.01.2018.
//  Copyright © 2018 Bartu Kovan. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    //Müzikler
    let swapSound = SKAction.playSoundFileNamed("Chomp.wav", waitForCompletion: false)
    let invalidSwapSound = SKAction.playSoundFileNamed("Error.wav", waitForCompletion: false)
    let matchSound = SKAction.playSoundFileNamed("Ka-Ching.wav", waitForCompletion: false)
    let fallingCookieSound = SKAction.playSoundFileNamed("Scrape.wav", waitForCompletion: false)
    let addCookieSound = SKAction.playSoundFileNamed("Drip.wav", waitForCompletion: false)
    
    var swipeHandler: ((Swap) -> ())?
    
    var level: Level!
    let TileWidth: CGFloat = 32.0
    let TileHeight: CGFloat = 36.0
    
    let gameLayer = SKNode()
    let cookiesLayer = SKNode()
    let tilesLayer = SKNode()
    var selectionSprite = SKSpriteNode()
    
    //bunlar playerin dokunduğu ilk cookie ve değiştirmek için seçeceği diğer cookieyi temsil ediyor
    //?'in sebebi playerimizin swap yapmadığı zamanki durumundan dolayı
    //seçim yapılmadığında nil olması gerekli
    private var swipeFromColumn: Int?
    private var swipeFromRow: Int?
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    //Anchor Point ve Background u Kodla oluşturmak
    //Seçilen Anchor Pointten Dolayı Background her zaman ortada olacak
    
    override init(size : CGSize) {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0.5,y: 0.5)
        
        let background = SKSpriteNode(imageNamed: "Background")
        background.size = size
        addChild(background)
       
        //Bu kod ekranımıza 2 tane layer gibi kullanıcağımız SKNode ekleyecek.
        addChild(gameLayer)
        let layerPosition = CGPoint(
            x: -TileWidth * CGFloat(NumColumns) / 2,
            y: -TileHeight * CGFloat(NumRows) / 2)
        
        cookiesLayer.position = layerPosition
        tilesLayer.position = layerPosition
        gameLayer.addChild(tilesLayer)
        gameLayer.addChild(cookiesLayer)
        
        
        //playerimiz henüz seçim yapmadığı için bunların başlangıçta nil olması gerekli
        swipeFromColumn = nil
        swipeFromRow = nil
        
    }
    //????????????????
    func addSprites(for cookies: Set<Cookie>) {
        for cookie in cookies {
            let sprite = SKSpriteNode(imageNamed: cookie.cookieType.spriteName)
            sprite.size = CGSize(width: TileWidth, height: TileHeight)
            sprite.position = pointFor(column: cookie.column, row: cookie.row)
            cookiesLayer.addChild(sprite)
            cookie.sprite = sprite
        }
    }
   
    
    //Bu döngü tüm satır ve sütunlar arası dönecek
    //Ve eğer ızgarada bir tile varsa yeni bir tile sprite oluşturup bunuda tiles layer a ekleyecek
    func addTiles() {
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if level.tileAt(column: column, row: row) != nil {
                    let tileNode = SKSpriteNode(imageNamed: "Tile")
                    tileNode.size = CGSize(width: TileWidth, height: TileHeight)
                    tileNode.position = pointFor(column: column, row: row)
                    tilesLayer.addChild(tileNode)
                }
            }
        }
    }
    
    //seçilen cookienin highlighted halini görmemizi sağlayacak fonksiyon
    func showSelectionIndicator(for cookie: Cookie) {
        if selectionSprite.parent != nil {
            selectionSprite.removeFromParent()
        }
        
        if let sprite = cookie.sprite {
            let texture = SKTexture(imageNamed: cookie.cookieType.highlightedSpriteName)
            selectionSprite.size = CGSize(width: TileWidth, height: TileHeight)
            selectionSprite.run(SKAction.setTexture(texture))
            
            sprite.addChild(selectionSprite)
            selectionSprite.alpha = 1.0
            
        }
    }
    
    func animateInvalidSwap(_ swap: Swap, completion: @escaping () -> ()) {
        let spriteA = swap.cookieA.sprite!
        let spriteB = swap.cookieB.sprite!
        
        spriteA.zPosition = 100
        spriteB.zPosition = 90
        
        let duration: TimeInterval = 0.2
        
        let moveA = SKAction.move(to: spriteB.position, duration: duration)
        moveA.timingMode = .easeOut
        
        let moveB = SKAction.move(to: spriteA.position, duration: duration)
        moveB.timingMode = .easeOut
        
        spriteA.run(SKAction.sequence([moveA, moveB]), completion: completion)
        spriteB.run(SKAction.sequence([moveB, moveA]))
        run(invalidSwapSound)
    }
    
    //column ve row u CGPoint e çevirir
    func pointFor(column: Int, row: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column)*TileWidth + TileWidth/2,
            y: CGFloat(row)*TileHeight + TileHeight/2 )
    }
    
    //pointFor fonksiyonumuz tersi
    //bu fonksiyon bir cookieslayer dan bir CGPoint alıp bunu bize column ve row number olarak verecek
    //eğer cookie ızgaramızın dışına çıkartılmaya çalışırsa false olarak geri dönecek
    func convertPoint(point: CGPoint) -> (success: Bool, column: Int, row: Int) {
        if point.x >= 0 && point.x < CGFloat(NumColumns)*TileWidth &&
            point.y >= 0 && point.y < CGFloat(NumRows)*TileHeight {
            return (true, Int(point.x / TileWidth), Int(point.y / TileHeight))
        } else {
            return (false, 0, 0) // grid dışarısı
        }
    }
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    override func didMove(to view: SKView) {
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //Bu dokunulan lokasyonu cookieslayerda bir point e dönüştürecek
        guard let touch = touches.first else { return }
        let location = touch.location(in: cookiesLayer)
        
        //Burası bize playerin 9x9 grid in içerisine dokunduğu ifade ediyor ve buna yönelik adımlara geçiyor
        let (success, column, row) = convertPoint(point: location)
        if success {
          
            //Burası bize bir cookie ye dokunulduğunu söylüyor
            if let cookie = level.cookieAt(column: column, row: row) {
                
                showSelectionIndicator(for: cookie)
                
                //Swipe hareketinin başlayacağı column ve row u bulduğumuz yer
                swipeFromColumn = column
                swipeFromRow = row
            }
        }
       
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //bu tamamen yapılan swapın grid içerisinde olmasını kontrol etmek amacıyla yazılmıştır
        guard swipeFromColumn != nil else { return }
        
        //playerin parmağının nerede olduğuna bakıyoruz aynı touchesBegan da olduğu gibi
        guard let touch = touches.first else { return }
        let location = touch.location(in: cookiesLayer)
        
        let (success, column, row) = convertPoint(point: location)
        if success {
            
            //Hareketin gerçekleştiği yer ve biz sadece 4 yöne hareket ediyoruz diogonel hareket yok
            //Bunları unwrap! etmemizin sebebi kesin olarak bir değere sahip olmamız ve başta kontrol mekanizması kullandığımız için
            var horzDelta = 0, vertDelta = 0
            if column < swipeFromColumn! { // sola kaydırır
                horzDelta = -1
            } else if column > swipeFromColumn! { // sağa kaydırır
                horzDelta = 1
            } else if row < swipeFromRow! { // aşağıya kaydırır
                vertDelta = -1
            } else if row < swipeFromRow! { // yukarıya kaydırır
                vertDelta = 1
            }
            
            //Burası ise swap ın gerçekleşmesi için playerin seçilen kareden çıkarması gerektiğini söylüyor
            if horzDelta != 0 || vertDelta != 0 {
                trySwap(horizontal: horzDelta, vertical: vertDelta)
                hideSelectionIndicator()
                
                //burayı nil e eşitliyoruz eğer yanlış bir swap yapılırsa eski haline dönsün diye
                //yanlış swap gridin dışına çıkarılması vb. gibi
                swipeFromColumn = nil
            }
        }

    }
    
    //Seçilen spritein fade out ile silinmesini sağlayacak
    func hideSelectionIndicator () {
        selectionSprite.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.3), SKAction.removeFromParent()
            ]))
    }
    
    func trySwap(horizontal horzDelta: Int, vertical vertDelta: Int) {
        
        //Değiştirelecek olan cookienin column ve row unu hesaplıyoruz
        let toColumn = swipeFromColumn! + horzDelta
        let toRow = swipeFromRow! + vertDelta
        
        //Kontrolümüzü gerçekleştiriyoruz grid dışına çıkılmasın diye
        guard toColumn >= 0 && toColumn < NumColumns else { return }
        guard toRow >= 0 && toRow < NumRows else { return }
        
        //Seçilen pozisyonda bir cookie olduğuna emin oluyoruz
        if let toCookie = level.cookieAt(column: toColumn, row: toRow),
            let fromCookie = level.cookieAt(column: swipeFromColumn!, row: swipeFromRow!) {
            
            //Swap ın gerçekleştiği yer
            if let handler = swipeHandler {
                let swap = Swap(cookieA: fromCookie, cookieB: toCookie)
                handler(swap)
            }
        }
    }
      //Animasyon fonksiyonumuz
    //kaç saniyede gerçekleşeceğini nasıl bi animasyonla gerçekleşeceğini tanımladık
    //() -> () ??????
    func animate(_ swap: Swap, completion: @escaping () -> ()) {
        let spriteA = swap.cookieA.sprite!
        let spriteB = swap.cookieB.sprite!
        
        spriteA.zPosition = 100
        spriteB.zPosition = 90
        
        let duration: TimeInterval = 0.3
        
        let moveA = SKAction.move(to: spriteB.position, duration: duration)
        moveA.timingMode = .easeOut
        spriteA.run(moveA, completion: completion)
        
        let moveB = SKAction.move(to: spriteA.position, duration: duration)
        moveB.timingMode = .easeOut
        spriteB.run(moveB)
        
        run(swapSound)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //Player switch yapmadığı zamanda highligted sprite ı geri alıyoruz
        if selectionSprite.parent != nil && swipeFromColumn != nil {
            hideSelectionIndicator()
        }

        //Swap bittikten sonra kullanıcı elini kaldırdığında değerlerimizi nil yapıyoruz
        swipeFromColumn = nil
        swipeFromRow = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //iptal etmek istedğinde  hiç bişey olsun istemiyoruz
        touchesEnded(touches, with: event)
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
