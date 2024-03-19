//
//  VectorCalc.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 05.03.24.
//

import Foundation

infix operator ** : MultiplicationPrecedence
extension Vector2 {
    
    func length() -> Float {
        return sqrtf(x * x + y * y)
    }
    
    mutating func normalize() {
        let scale = 1 / self.length()
        x *= scale
        y *= scale
    }
    
    func normalized() -> Vector2 {
        let scale = 1 / self.length()
        return scale * self
    }
    
    static func + (lhs: Vector2, rhs: Vector2) -> Vector2 {
        return Vector2(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func - (lhs: Vector2, rhs: Vector2) -> Vector2 {
        return Vector2(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    static func * (lhs: Float, rhs: Vector2) -> Vector2 {
        return Vector2(x: lhs * rhs.x, y: lhs * rhs.y)
    }
    
    static func / (lhs: Vector2, rhs: Float) -> Vector2 {
        return Vector2(x: lhs.x / rhs, y: lhs.y / rhs)
    }
    
    static func ** (lhs: Vector2, rhs: Vector2) -> Float {
        return lhs.x * rhs.x + lhs.y * rhs.y
    }
    
}

infix operator *-* : MultiplicationPrecedence
extension Vector3 {
    
    func length() -> Float {
        return sqrtf(x * x + y * y + z * z)
    }
    
    mutating func normalize() {
        let scale = 1 / self.length()
        x *= scale
        y *= scale
        z *= scale
    }
    
    func normalized() -> Vector3 {
        let scale = 1 / self.length()
        return scale * self
    }
    
    static func + (lhs: Vector3, rhs: Vector3) -> Vector3 {
        return Vector3(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
    }
    
    static func - (lhs: Vector3, rhs: Vector3) -> Vector3 {
        return Vector3(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
    }
    
    static func * (lhs: Float, rhs: Vector3) -> Vector3 {
        return Vector3(x: lhs * rhs.x, y: lhs * rhs.y, z: lhs * rhs.z)
    }
    
    static func / (lhs: Vector3, rhs: Float) -> Vector3 {
        return Vector3(x: lhs.x / rhs, y: lhs.y / rhs, z: lhs.z / rhs)
    }
    
    static func ** (lhs: Vector3, rhs: Vector3) -> Float {
        return lhs.x * rhs.x + lhs.y * rhs.y + lhs.z * rhs.z
    }
    
    static func *-* (lhs: Vector3, rhs: Vector3) -> Vector3 {
        return Vector3(x: lhs.y * rhs.z - lhs.z * rhs.y,
                       y: lhs.z * rhs.x - lhs.x * rhs.z,
                       z: lhs.x * rhs.y - lhs.y * rhs.x)
    }
    
}

infix operator -*- : MultiplicationPrecedence
infix operator *** : MultiplicationPrecedence
infix operator --- : AdditionPrecedence
infix operator +++ : AdditionPrecedence
extension Vector4 {
    
    func length() -> Float {
        return sqrtf(x * x + y * y + z * z + t * t)
    }
    
    func length3() -> Float {
        return sqrtf(x * x + y * y + z * z)
    }
    
    mutating func normalize() {
        let scale = 1 / self.length()
        x *= scale
        y *= scale
        z *= scale
        t *= scale
    }
    
    mutating func normalize3() {
        let scale = 1 / self.length3()
        x *= scale
        y *= scale
        z *= scale
    }
    
    func normalized() -> Vector4 {
        let scale = 1 / self.length()
        return scale * self
    }
    
    func normalized3() -> Vector4 {
        let scale = 1 / self.length3()
        return scale *** self
    }
    
    static func +++ (lhs: Vector4, rhs: Vector4) -> Vector4 {
        return Vector4(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z, t: lhs.t)
    }
    
    static func --- (lhs: Vector4, rhs: Vector4) -> Vector4 {
        return Vector4(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z, t: lhs.t)
    }
    
    static func *** (lhs: Float, rhs: Vector4) -> Vector4 {
        return Vector4(x: lhs * rhs.x, y: lhs * rhs.y, z: lhs * rhs.z, t: rhs.t)
    }
    
    static func -*- (lhs: Vector4, rhs: Float) -> Vector4 {
        return Vector4(x: lhs.x / rhs, y: lhs.y / rhs, z: lhs.z / rhs, t: lhs.t)
    }
    
    static func *** (lhs: Vector4, rhs: Vector4) -> Float {
        return lhs.x * rhs.x + lhs.y * rhs.y + lhs.z * rhs.z
    }
    
    static func + (lhs: Vector4, rhs: Vector4) -> Vector4 {
        return Vector4(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z, t: lhs.t + rhs.t)
    }
    
    static func - (lhs: Vector4, rhs: Vector4) -> Vector4 {
        return Vector4(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z, t: lhs.t - rhs.t)
    }
    
    static func * (lhs: Float, rhs: Vector4) -> Vector4 {
        return Vector4(x: lhs * rhs.x, y: lhs * rhs.y, z: lhs * rhs.z, t: lhs * rhs.t)
    }
    
    static func / (lhs: Vector4, rhs: Float) -> Vector4 {
        return Vector4(x: lhs.x / rhs, y: lhs.y / rhs, z: lhs.z / rhs, t: lhs.t / rhs)
    }
    
    static func * (lhs: Vector4, rhs: Vector4) -> Float {
        return lhs.x * rhs.x + lhs.y * rhs.y + lhs.z * rhs.z + lhs.t * rhs.t
    }
    
}
