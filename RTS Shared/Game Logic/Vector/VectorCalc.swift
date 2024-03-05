//
//  VectorCalc.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 05.03.24.
//

import Foundation

extension Vector {
    
    func length() -> Float {
        return sqrtf(x * x + y * y)
    }
    
    mutating func normalize() {
        let scale = 1 / self.length()
        x *= scale
        y *= scale
    }
    
    func normalized() -> Vector {
        let scale = 1 / self.length()
        return scale * self
    }
    
    static func + (lhs: Vector, rhs: Vector) -> Vector {
        return Vector(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func - (lhs: Vector, rhs: Vector) -> Vector {
        return Vector(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    static func * (lhs: Float, rhs: Vector) -> Vector {
        return Vector(x: lhs * rhs.x, y: lhs * rhs.y)
    }
    
    static func / (lhs: Vector, rhs: Float) -> Vector {
        return Vector(x: lhs.x / rhs, y: lhs.y / rhs)
    }
    
    static func * (lhs: Vector, rhs: Vector) -> Float {
        return lhs.x * rhs.x + lhs.y * rhs.y
    }
    
}
