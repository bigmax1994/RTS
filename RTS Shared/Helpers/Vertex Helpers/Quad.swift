//
//  Quad.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 15.03.24.
//

import Foundation
import simd

struct Quad {
    
    var verticies: [Vertex]
    var color: simd_float3
    
    init(verticies: [Vertex]) {
        assert(verticies.count == 4, "quad without 4 verticies")
        self.verticies = verticies
        self.color = verticies[0].color
    }
    
    init(from: Vector2, to: Vector2, color: [Float]) {
        
        let v1 = Vertex(pos: from)
        let v2 = Vertex(x: from.x, y: to.y)
        let v3 = Vertex(x: from.y, y: to.x)
        let v4 = Vertex(pos: from)
        
        self.verticies = [v1, v2, v3, v4]
        self.color = simd_float3(color)
        
    }
    
    init(from: Vector2, to: Vector2, z: Float, color: [Float]) {
        
        let v1 = Vertex(x: from.x, y: from.y, z: z)
        let v2 = Vertex(x: from.x, y: to.y, z: z)
        let v3 = Vertex(x: from.y, y: to.x, z: z)
        let v4 = Vertex(x: to.x, y: to.y, z: z)
        
        self.verticies = [v1, v2, v3, v4]
        self.color = simd_float3(color)
        
    }
    
    init(fromX: Float, fromY: Float, toX: Float, toY: Float, color: [Float]) {
        
        let v1 = Vertex(x: fromX, y: fromY, color: color)
        let v2 = Vertex(x: fromX, y: toY, color: color)
        let v3 = Vertex(x: toX, y: fromY, color: color)
        let v4 = Vertex(x: fromX, y: toY, color: color)
        let v5 = Vertex(x: toX, y: fromY, color: color)
        let v6 = Vertex(x: toX, y: toY, color: color)
        
        self.verticies = [v1, v2, v3, v4, v5, v6]
        self.color = simd_float3(color)
        
    }
    
    init(fromX: Float, fromY: Float, toX: Float, toY: Float, z: Float, color: [Float]) {
        
        let v1 = Vertex(x: fromX, y: fromY, z: z, color: color)
        let v2 = Vertex(x: fromX, y: toY, z: z, color: color)
        let v3 = Vertex(x: toX, y: fromY, z: z, color: color)
        let v4 = Vertex(x: fromX, y: toY, z: z, color: color)
        let v5 = Vertex(x: toX, y: fromY, z: z, color: color)
        let v6 = Vertex(x: toX, y: toY, z: z, color: color)
        
        self.verticies = [v1, v2, v3, v4, v5, v6]
        self.color = simd_float3(color)
        
    }
    
}
