//
//  Vector.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 05.03.24.
//

import Foundation

struct Vector2 {
    var x: Float
    var y: Float
    
    init() {
        x = 0
        y = 0
    }
    
    init(x: Float, y: Float) {
        self.x = x
        self.y = y
    }
    
    init(angle: Float, length: Float = 1) {
        self.x = length * cos(angle)
        self.y = length * sin(angle)
    }
    
    func toArray() -> [Float] {
        return [x,y]
    }
    
}
