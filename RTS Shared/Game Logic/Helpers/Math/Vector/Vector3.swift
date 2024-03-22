//
//  Vector3.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 08.03.24.
//

import Foundation

struct Vector3: Byteable, Equatable {
    
    static var byteSize: Int = 3 * Float.byteSize
    
    var data: Data {
        var data = x.data
        data.append(y.data)
        data.append(z.data)
        
        return data
    }
    
    init(_ data: Data) {
        
        let xData = data.subdata(in: 0 ..< Float.byteSize)
        let yData = data.subdata(in: Float.byteSize ..< 2 * Float.byteSize)
        let zData = data.subdata(in: 2 * Float.byteSize ..< 3 * Float.byteSize)
        
        self.x = Float(xData)
        self.y = Float(yData)
        self.z = Float(zData)
        
    }
    
    var x: Float
    var y: Float
    var z: Float
    
    init() {
        x = 0
        y = 0
        z = 0
    }

    init(_ simd: simd_float3) {
        x = simd.x
        y = simd.y
        z = simd.z
    }
    
    init(x: Float, y: Float, z: Float) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    init(phi: Float, theta: Float, length: Float = 1) {
        self.x = length * cos(phi) * cos(theta)
        self.y = length * sin(phi) * cos(theta)
        self.z = length * sin(theta)
    }
    
    func toArray() -> [Float] {
        return [x,y,z]
    }
    
    func toSIMD() -> simd_float3 {
        
        return simd_float3(self.x, self.y, self.z)
        
    }
    
    func getAnyLinearlyIndipendent() -> Vector3 {
        
        var v = Vector3(x: 1, y: 0, z: 0)
        if abs(v ** self) > 3 * Float.ulpOfOne {
            v = Vector3(x: 0, y: 1, z: 0)
        }
        
        return v *-* self
        
    }
    
}
