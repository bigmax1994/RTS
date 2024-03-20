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
        
        let light = Vector3(x: 1, y: 0, z: 1).normalized()
        
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
                
                let h1 = map.heightMap.evaluate(v: v1)
                let h2 = map.heightMap.evaluate(v: v2)
                let h3 = map.heightMap.evaluate(v: v3)
                let h4 = map.heightMap.evaluate(v: v4)
                
                let v31 = Vector3(x: v1.x, y: v1.y, z: h1)
                let v32 = Vector3(x: v2.x, y: v2.y, z: h2)
                let v33 = Vector3(x: v3.x, y: v3.y, z: h3)
                let v34 = Vector3(x: v4.x, y: v4.y, z: h4)
                
                let n1 = (v31 - v32) *-* (v31 - v33)
                let n2 = (v32 - v34) *-* (v32 - v33)
                
                let l1 = abs(n1.normalized() ** light)
                let l2 = abs(n2.normalized() ** light)
                
                let c1 = RTSRenderer.sampleMapColor(from: map, at: v1, fac: l1)
                let c2 = RTSRenderer.sampleMapColor(from: map, at: v2, fac: l1)
                let c3 = RTSRenderer.sampleMapColor(from: map, at: v3, fac: l2)
                let c4 = RTSRenderer.sampleMapColor(from: map, at: v4, fac: l2)
                
                verticies.append(Vertex(pos: v1, z: h1, color: c1))
                verticies.append(Vertex(pos: v2, z: h2, color: c2))
                verticies.append(Vertex(pos: v3, z: h3, color: c3))
                verticies.append(Vertex(pos: v2, z: h2, color: c2))
                verticies.append(Vertex(pos: v3, z: h3, color: c3))
                verticies.append(Vertex(pos: v4, z: h4, color: c4))
                
            }
            
        }
        print("min: \(map.heightMap.min), max: \(map.heightMap.max)")
        return verticies
        
    }
    
    static func sampleMapColor(from map: RTSMap, at pos: Vector2, fac: Float) -> [Float] {
        
        let tileIndex = map.position_to_tileIndex(pos + (map.tileSize / 2) * (Vector2.RIGHT + Vector2.UP))
        
        switch map.tiles[tileIndex] {
        case .grass:
            return [0, fac, 0]
        case .water:
            return [0, 0, fac]
        case .mountain:
            return [fac * 0.7631, fac * 0.4432, fac * 0.1306]
        case .post:
            return [fac * 0.5, fac * 0.5, fac * 0.5]
        case .activePost:
            return [fac * 0.4176, fac * 0.4153, fac * 0.7561]
        case .closedPost:
            return [fac * 0.6186, fac * 0.4153, fac * 0.7561]
        case .forbidden:
            return [fac * 1,0,0]
        case .border:
            return [fac * 0.4, fac * 0.4, fac * 0.4]
        }
    }
    
}
