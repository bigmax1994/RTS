//
//  Vertex.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 09.03.24.
//

import Foundation
import simd

struct Vertex {
    
    var pos: simd_float3
    var color: simd_float3
    
    init(pos: simd_float3, color: simd_float3) {
        self.pos = pos
        self.color = color
    }
    
    init(pos: Vector3, color: [Float]) {
        
        assert(color.count == 3, "incorrect color length")
        
        self.pos = simd_float3(pos.x, pos.y, pos.z)
        self.color = simd_float3(color)
        
    }
    
    init(pos: Vector3) {
        
        self.pos = simd_float3(pos.x, pos.y, pos.z)
        self.color = simd_float3(repeating: 0)
        
    }
    
    init(pos: Vector2) {
        
        self.pos = simd_float3(pos.x, pos.y, 0)
        self.color = simd_float3(repeating: 0)
        
    }
    
    init(x: Float, y: Float, z: Float) {
        
        self.pos = simd_float3(x, y, z)
        self.color = simd_float3(repeating: 0)
        
    }
    
    init(x: Float, y: Float) {
        
        self.pos = simd_float3(x, y, 0)
        self.color = simd_float3(repeating: 0)
        
    }
    
    init(x: Float, y: Float, color: [Float]) {
        
        self.pos = simd_float3(x, y, 0)
        self.color = simd_float3(color)
        
    }
    
    init(x: Float, y: Float, z: Float, color: [Float]) {
        
        self.pos = simd_float3(x, y, z)
        self.color = simd_float3(color)
        
    }
    
}
