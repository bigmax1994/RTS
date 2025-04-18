//
//  Uniforms.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 19.03.24.
//

import Foundation
import simd
import Metal

extension Transformation: GPUEncodable {
    
    init(matrix: Matrix, position: Vector3, size: Vector3) {
        
        self.init()
        
        self.m = matrix.matrix3x3ToSIMD()
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
        
        self.m = m.matrix3x3ToSIMD()
        
    }
    
    mutating func rotateBy(_ m: Matrix) {
        
        self.m = simd_mul(m.matrix3x3ToSIMD(), self.m)
        
    }
    
    mutating func scaleTo(_ s: Vector3) {
        
        self.s = s.toSIMD()
        
    }
    
    mutating func scaleTo(_ s: Float) {
        
        self.s = simd_float3(repeating: s)
        
    }
    
    mutating func scaleBy(_ s: Vector3) {
        
        self.s = simd_float3(s.x * self.s.x, s.y * self.s.y, s.z * self.s.z)
        
    }
    
    mutating func scaleBy(_ s: Float) {
        
        self.s = simd_float3(s * self.s.x, s * self.s.y, s * self.s.z)
        
    }
    
}
