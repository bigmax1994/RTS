//
//  Vector.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 05.03.24.
//

import Foundation

struct Vector2: Byteable {
    
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

    static func random() -> Vector2 {
        return Vector2(x: random(min: -1, max: 1), y: random(min: -1, max: 1))
    }
    
    static let byteSize: Int = 2 * Float.byteSize
    
    var data: Data {
        
        var data = x.data
        data.append(y.data)
        
        return data
    }
    
    init(_ data: Data) {
        
        let xData = data.subdata(in: 0 ..< Float.byteSize)
        let yData = data.subdata(in: Float.byteSize ..< 2 * Float.byteSize)
        
        self.x = Float(xData)
        self.y = Float(yData)
        
    }
    
}
