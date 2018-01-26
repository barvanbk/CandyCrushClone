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
    
    
    
    //shuffle methodu bizim levelimizi random cookiler ile dolduracak
    
    
    func shuffle() -> Set<Cookie> {
        return createInitialCokkies()
    }
    
    private func createInitialCokkies() -> Set<Cookie> {
        var set = Set<Cookie>()
        
        //1
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                
                if tiles[column,row] != nil {
                
                //Oluşturduğumuz random fonksiyonunu çağırıp randon cookie seçtik
                let cookieType = CookieType.random()
                
                //bir cookie oluşturup 2Darray e ekler
                let cookie = Cookie(column: column, row: row, cookieType: cookieType)
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


