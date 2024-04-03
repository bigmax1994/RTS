//
//  Map Sample.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 19.03.24.
//

import Foundation
import Metal

extension RTSRenderer {
    
    ///samples the map and returns a buffer of verticies to be rendered
    static func sampleMap(from map: RTSMap, with LOD: Int) -> [Vertex] {
        
        if LOD < 1 {
            fatalError("incorrect LOD")
        }
        
        var verticies:[Vertex] = []
        
        for x in 1...LOD {
            
            let xStart = 2 * Float(x - 1) / Float(LOD) - 1
            let xEnd = 2 * Float(x) / Float(LOD) - 1
            
            for y in 1...LOD {
                
                let yStart = 2 * Float(y - 1) / Float(LOD) - 1
                let yEnd = 2 * Float(y) / Float(LOD) - 1
                
                let v1 = Vector2(x: xStart, y: yStart)
                let v2 = Vector2(x: xStart, y: yEnd)
                let v3 = Vector2(x: xEnd, y: yStart)
                let v4 = Vector2(x: xEnd, y: yEnd)
                
                let (h1, g1) = map.heightMap.evaluate(v: v1)
                let (h2, g2) = map.heightMap.evaluate(v: v2)
                let (h3, g3) = map.heightMap.evaluate(v: v3)
                let (h4, g4) = map.heightMap.evaluate(v: v4)
                
                let v31 = Vector3(x: v1.x, y: v1.y, z: h1)
                let v32 = Vector3(x: v2.x, y: v2.y, z: h2)
                let v33 = Vector3(x: v3.x, y: v3.y, z: h3)
                let v34 = Vector3(x: v4.x, y: v4.y, z: h4)
                
                let n1 = -1 * ((v31 - v32) *-* (v31 - v33)).normalized()
                let n2 = -1 * ((v32 - v34) *-* (v32 - v33)).normalized()
                
                let c1 = RTSRenderer.sampleMapColor(from: map, at: v1)
                let c2 = RTSRenderer.sampleMapColor(from: map, at: v2)
                let c3 = RTSRenderer.sampleMapColor(from: map, at: v3)
                let c4 = RTSRenderer.sampleMapColor(from: map, at: v4)
                
                verticies.append(Vertex(pos: v31, normal: n1, material: c1))
                verticies.append(Vertex(pos: v32, normal: n1, material: c2))
                verticies.append(Vertex(pos: v33, normal: n1, material: c3))
                verticies.append(Vertex(pos: v32, normal: n2, material: c2))
                verticies.append(Vertex(pos: v33, normal: n2, material: c3))
                verticies.append(Vertex(pos: v34, normal: n2, material: c4))
                
            }
            
        }
        
        return verticies
        
    }
    
    static func sampleMapColor(from map: RTSMap, at pos: Vector2) -> Material {
        
        let tileIndex = map.position_to_tileIndex(pos + (map.tileSize / 2) * (Vector2.RIGHT + Vector2.UP))
        
        switch map.tiles[tileIndex] {
        case .grass:
            return Material(color: Color.green, shininess: 4)
        case .water:
            return Material(color: Color.blue, shininess: 64)
        case .mountain:
            return Material(color: Color.brown, shininess: 8)
        case .post:
            return Material(color: Color.grey)
        case .activePost:
            return Material(color: Color.grey)
        case .closedPost:
            return Material(color: Color.grey)
        case .forbidden:
            return Material(color: Color.red)
        case .border:
            return Material(color: Color.grey)
        case .steep:
            return Material(color: Color.grey, shininess: 100)
        }
    }
    
}
