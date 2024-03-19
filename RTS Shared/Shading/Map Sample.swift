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
                
                let h1 = map.heightMap.evaluate(v: v1) / 10
                let h2 = map.heightMap.evaluate(v: v2) / 10
                let h3 = map.heightMap.evaluate(v: v3) / 10
                let h4 = map.heightMap.evaluate(v: v4) / 10
                
                let c1 = [Float](repeating: h1, count: 3)//RTSRenderer.sampleMapColor(from: map, at: v1)
                let c2 = [Float](repeating: h2, count: 3)//RTSRenderer.sampleMapColor(from: map, at: v2)
                let c3 = [Float](repeating: h3, count: 3)//RTSRenderer.sampleMapColor(from: map, at: v3)
                let c4 = [Float](repeating: h4, count: 3)//RTSRenderer.sampleMapColor(from: map, at: v4)
                
                verticies.append(Vertex(pos: v1, z: h1, color: c1))
                verticies.append(Vertex(pos: v2, z: h2, color: c2))
                verticies.append(Vertex(pos: v3, z: h3, color: c3))
                verticies.append(Vertex(pos: v2, z: h2, color: c2))
                verticies.append(Vertex(pos: v3, z: h3, color: c3))
                verticies.append(Vertex(pos: v4, z: h4, color: c4))
                
            }
            
        }
        
        return verticies
        
    }
    
    static func sampleMapColor(from map: RTSMap, at pos: Vector2) -> [Float] {
        
        let tileIndex = map.position_to_tileIndex(pos + (map.tileSize / 2) * (Vector2.RIGHT + Vector2.UP))
        
        print("tileIndex: \(tileIndex), pos: \(pos)")
        switch map.tiles[tileIndex] {
        case .grass:
            return [0, 1, 0]
        case .water:
            return [0, 0, 1]
        case .mountain:
            return [0.7631, 0.4432, 0.1306]
        case .post:
            return [0.5, 0.5, 0.5]
        case .activePost:
            return [0.4176, 0.4153, 0.7561]
        case .closedPost:
            return [0.6186, 0.4153, 0.7561]
        case .forbidden:
            return [0,0,0]
        case .border:
            return [0.4, 0.4, 0.4]
        default:
            return [0,0,0]
        }
        
    }
    
}
