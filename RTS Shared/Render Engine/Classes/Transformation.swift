//
//  Uniforms.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 19.03.24.
//

import Foundation
import simd

struct Transformation: GPUEncodable {
    
    var m: simd_float4x4
    var p: simd_float3
    var s: simd_float3
    
    init(matrix: Matrix, position: Vector3, size: Vector3) {
        self.m = matrix.matrix4x4ToSIMD()
        self.p = position.toSIMD()
        self.s = size.toSIMD()
    }
    
    mutating func moveTo(_ pos: Vector3) {
        
        self.p = simd_float3(pos.x, pos.y, pos.z)
        
    }
    
    mutating func moveBy(_ pos: Vector3) {
        
        self.p = self.p + simd_float3(pos.x, pos.y, pos.z)
        
    }
    
    mutating func rotateTo(_ m: Matrix) {
        
        self.m = m.matrix4x4ToSIMD()
        
    }
    
    mutating func rotateBy(_ m: Matrix) {
        
        self.m = simd_mul(self.m, m.matrix4x4ToSIMD())
        
    }
    
    mutating func scaleTo(_ s: Vector3) {
        
        self.s = s.toSIMD()
        
    }
    
    mutating func scaleBy(_ s: Vector3) {
        
        self.s = simd_float3(s.x * self.s.x, s.y * self.s.y, s.z * self.s.z)
        
    }
    
    mutating func scaleBy(_ s: Float) {
        
        self.s = simd_float3(s * self.s.x, s * self.s.y, s * self.s.z)
        
    }
    
}
