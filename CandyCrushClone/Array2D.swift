//
//  Array2D.swift
//  CandyCrushClone
//
//  Created by Bartu Kovan on 24.01.2018.
//  Copyright © 2018 Bartu Kovan. All rights reserved.
//

//Array2D cookieleri tutma amaçlı kullanılacak
//Array2D<T> nin anlamı T tipindeki tüm elemanları saklayacak sayısal(generic) bir şey. --??????





struct Array2D<T> {
    let columns: Int
    let rows: Int
    fileprivate var array: Array<T?>
    
    init(columns: Int, rows: Int) {
        self.columns = columns
        self.rows = rows
        array = Array<T?>(repeating: nil, count: rows*columns)
        
    }
    
    subscript(column: Int, row: Int) -> T? {
        get {
            return array[row*columns + column]
        }
        set {
            array [row*columns + column] = newValue
        }
    }
    
    
    
}
