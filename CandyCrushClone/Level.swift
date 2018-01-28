//
//  Level.swift
//  CandyCrushClone
//
//  Created by Bartu Kovan on 24.01.2018.
//  Copyright © 2018 Bartu Kovan. All rights reserved.
//

import Foundation

let NumColumns = 9
let NumRows = 9

class Level {
   
    fileprivate var cookies = Array2D<Cookie>(columns: NumColumns, rows: NumRows)
    private var tiles = Array2D<Tile>(columns: NumColumns, rows: NumRows)
    
    private var possibleSwaps = Set<Swap>()
   
    
    //JSON ile ilgili kodlar
    init(filename: String){
        
        
        //Dictionary i çağırdığımız yer , loadJSONFromBundle ile çağırıyoruz
        //guard kullanmamızın sebebi bu nil olarakta geri dönebilir
        guard let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename: filename)
            else { return }
        //Bu dictionarynin sahip olduğu bir dizi var adı tiles
        //Bu dizide her elemanın bir satırda ve bir sütunda yer alacağını söylüyor ????
        guard let tilesArray = dictionary["tiles"] as? [[Int]] else { return }
        //Enumerated fonksiyonu bize o anki row sayısını söylüyor
        for (row, rowArray) in tilesArray.enumerated() {
            //Rowların sıralanmasını tersine çeviriyoruz burda
            //Bunun sebebi ise JSON'da okuduğumuz ilk row normalde 2D ızgaranın en son rowunu temsil ediyor
            let tileRow = NumRows - row - 1
            //Her seferinde sonucu 1 bulacak ve bir tile oluşturacak bize ve bunu tiles içerisinde yapacak
            for (column, value) in rowArray.enumerated() {
                if value == 1 {
                    tiles[column, tileRow] = Tile()
                }
            }
        }
    }
    
    // Cookienin sonundaki soru işaretinin sebebi her yerin cookie olmama ihtimali bazı yerlerin boşluk olma ihtimalindendir
    func cookieAt(column:Int , row:Int) -> Cookie? {
        
        // assert ile ilgili edindiğim bilgilere göre
        //bu kod uygulamamızı crash ettirebilir fakat
        //problemin nasıl kaynaklandığını çözmemizde bize kolaylık sağlar
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return cookies[column,row]
    }
    
    //İstenmeyen Swaplara kesin çözüm
    func isPossibleSwap(_ swap: Swap) -> Bool {
        return possibleSwaps.contains(swap)
    }
    
    
    
    //shuffle methodu bizim levelimizi random cookiler ile dolduracak
    
    
    func shuffle() -> Set<Cookie> {
        var set: Set<Cookie>
        repeat {
            set = createInitialCokkies()
            detectPossibleSwaps()
            print("possible swaps: \(possibleSwaps)")
        } while possibleSwaps.count == 0
        return set
    }
    
    //Chain Kontrol fonksiyonumuz
    private func hasChainAt(column: Int, row: Int) -> Bool {
        let cookieType = cookies[column, row]!.cookieType
        
        //Yatay chain var mı kontrol
        var horzLength = 1
        
        //Sol
        var i = column - 1
        while i >= 0 && cookies[i, row]?.cookieType == cookieType {
            i -= 1
            horzLength += 1
        }
        
        //Sağ
        i = column + 1
        while i < NumColumns && cookies[i, row]?.cookieType == cookieType {
            i += 1
            horzLength += 1
        }
        if horzLength >= 3 { return true }
        
        //Dikey chain var mı kontrol
        var vertLength = 1
        
        //Aşağı
        i = row - 1
        while i >= 0 && cookies[column, i]?.cookieType == cookieType {
            i -= 1
            vertLength += 1
        }
        
        //Yukarı
        i = row + 1
        while i < NumRows && cookies[column, i]?.cookieType == cookieType {
            i += 1
            vertLength += 1
        }
        
        return vertLength >= 3
    }
  
    //PossibleSwapsları yakaladığımız bölüm burası
    //Şimdilik sadece öğrenme amaçlı yapılmıştır kullanıcıya gösterilmeyecektir
    //Ama Debug panelden biz hangilerinin swaplanabilir olduğunu görebileceğiz
    
    func detectPossibleSwaps() {
        var set = Set<Swap>()
        
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if let cookie = cookies[column, row] {
                    
                    //Sağdaki cookie ile seçili cookiyi swap yapmamız mümkün mü ?
                    if column < NumColumns - 1 {
                        
                        //Bu noktada bir cookie var mı ?
                        if let other = cookies[column + 1, row] {
                            
                            //Swapla
                            cookies[column, row] = other
                            cookies[column + 1, row] = cookie
                            
                            //Bulunan cookie chain oluşturdu mu ?
                            if hasChainAt(column: column + 1, row: row) ||
                                hasChainAt(column: column, row: row) {
                                set.insert(Swap(cookieA: cookie, cookieB: other))
                        }
                            //Oluşturmadı. Geri Swapla
                            cookies[column, row] = cookie
                            cookies[column + 1, row] = other
                    }
                    
                }
                    
                    if row < NumRows - 1 {
                        if let other = cookies[column, row + 1] {
                            cookies[column, row] = other
                            cookies[column, row + 1] = cookie
                            
                            if hasChainAt(column: column, row: row + 1) ||
                                hasChainAt(column: column, row: row) {
                                set.insert(Swap(cookieA: cookie, cookieB: other))
                            }
                            
                             cookies[column, row] = cookie
                            cookies[column, row + 1] = other
                        }
                    }
                }
            }
        }
        
        possibleSwaps = set
    }
    
    func performSwap(swap: Swap) {
        let columnA = swap.cookieA.column
        let rowA = swap.cookieA.row
        let columnB = swap.cookieB.column
        let rowB = swap.cookieB.row
        
        cookies[columnA, rowA] = swap.cookieB
        swap.cookieB.column = columnA
        swap.cookieB.row = rowA
        
        cookies[columnB, rowB] = swap.cookieA
        swap.cookieA.column = columnB
        swap.cookieA.row = rowB
    }
    
    private func createInitialCokkies() -> Set<Cookie> {
        var set = Set<Cookie>()
        
        //1
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                
                if tiles[column,row] != nil {
                
                    //Burada yazdıklarımız sayesinde hiç bir zaman 3 tane cookie yan yana gelemeyecek
                    //Oyun başında ve Sonunda 3 tane yan yana kalmış cookie olmayacak
                    var cookieType: CookieType
                    repeat {
                        cookieType = CookieType.random()
                    } while (column >= 2 &&
                    cookies[column - 1, row]?.cookieType == cookieType &&
                    cookies[column - 2, row]?.cookieType == cookieType) ||
                    (row >= 2 &&
                    cookies[column, row - 1]?.cookieType == cookieType &&
                    cookies[column, row - 2]?.cookieType == cookieType)
                
                //bir cookie oluşturup 2Darray e ekler
                
                    let  cookie = Cookie(column: column, row: row, cookieType: cookieType)
                    cookies[column, row] = cookie
                
                
                //Yeni cookieyi bir kümeye ekler 
                set.insert(cookie)
                }
            }
        }
        return set
    }
    
    func tileAt(column: Int, row: Int) -> Tile? {
        assert(column >= 0 && row < NumRows)
        assert(row >= 0 && row < NumRows)
        return tiles[column, row]
    }
}


