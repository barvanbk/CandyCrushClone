//
//  Cookie.swift
//  CandyCrushClone
//
//  Created by Bartu Kovan on 23.01.2018.
//  Copyright © 2018 Bartu Kovan. All rights reserved.
//

import Foundation
import SpriteKit
        // Cookieler tanımlandı
        //0 tanımı boşlukları ifade ediyor
// Enumun printable olması için CustomStringConvetible kullanıldı
enum CookieType: Int, CustomStringConvertible {
    case unknown = 0, croissant, cupcake, danish, donut, macaroon, sugearCookie 
    
    // Her zaman farklı cookie gelmesi için
    // +1 in sebebi 0-5 arasını hesaplıyor ama amacımız 1-6 arasından birşey seçmek
    static func random() -> CookieType {
        return CookieType(rawValue: Int(arc4random_uniform(6)) + 1)!
    }
    
    
    //Oyuncu üzerine tıkladığında tıkladığı şeyin ismini görebilecek
    //Muhtemelen oluşturulan tabloda dönmesi için kullanılacak
    //-1 in sebebi crossiant şu an 1 numaralı ama 0 dan başladığı için
    var spriteName: String {
        let spriteNames = [
        "Croissant",
        "Cupcake",
        "Danish",
        "Donut",
        "Macaroon",
        "SugarCookie"]
    
        return spriteNames[rawValue - 1]
    }
    
    var highlightedSpriteName: String {
        return spriteName + "-Highlighted"
    }
    
    var description: String {
        return spriteName
    }
    
    
}

     // Kutucuklar oluşturuldu
// Cookieleri print etmek için CustomStringConvertible kullanıldı
//Hashable Protocolu ile yaptığımız burdaki coookie class ı bir küme şekline kullanmamızı sağlamak ?!?
class Cookie: CustomStringConvertible, Hashable {
   
    var column: Int
    var row: Int
    let cookieType: CookieType
    var sprite: SKSpriteNode?
    
    static func ==(lhs: Cookie, rhs: Cookie) -> Bool {
        return lhs.column == rhs.column && lhs.row == rhs.row
    }
    
    
    
    
    init(column: Int, row: Int, cookieType: CookieType) {
        
        self.column = column
        self.row = row
        self.cookieType = cookieType
    }
    
    var description: String{
        return "type:\(cookieType) square:(\(column),\(row))"
    }
    
    var hashValue: Int {
        return row*10 + column
    }
}
