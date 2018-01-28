//
//  Swap.swift
//  CandyCrushClone
//
//  Created by Bartu Kovan on 27.01.2018.
//  Copyright © 2018 Bartu Kovan. All rights reserved.
//

import Foundation


struct Swap: CustomStringConvertible, Hashable {
   
    //hashable hale getirdik bu sayede cookieler bir chain oluşturmadığında hata vereceğiz
    static func ==(lhs: Swap, rhs: Swap) -> Bool {
        return (lhs.cookieA == rhs.cookieA && lhs.cookieB == rhs.cookieB) ||
        (lhs.cookieB == rhs.cookieA && lhs.cookieA == rhs.cookieB)
    }
    
    
    var hashValue: Int {
        return cookieA.hashValue ^ cookieB.hashValue
    }
    let cookieA: Cookie
    let cookieB: Cookie
    
    init(cookieA: Cookie, cookieB: Cookie) {
        self.cookieA = cookieA
        self.cookieB = cookieB
    }
    
    var description: String {
        return "swap \(cookieA) with \(cookieB)"
    }
}
