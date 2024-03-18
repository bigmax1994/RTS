//
//  Matrix.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 18.03.24.
//

import Foundation

struct Matrix {
    
    var elements: [Float]
    var columns: Int
    var rows: Int
    
    init(elements: [Float], columns: Int, rows: Int) {
        
        self.elements = elements
        self.columns = columns
        self.rows = rows
        
    }
    
    init(_ elements: [[Float]]) {
        
        self.elements = elements.reduce(into: [Float]()) { partialResult, r in
            partialResult.append(contentsOf: r)
        }
        self.columns = elements[0].count
        self.rows = elements.count
        
    }
    
    init(columns: Int, rows: Int) {
        
        self.elements = [Float](repeating: 0, count: columns * rows)
        self.columns = columns
        self.rows = rows
        
    }
    
}
