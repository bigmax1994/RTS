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
    func sampleMap(with LOD: Int) -> MTLBuffer {
        
        if LOD < 1 {
            return MTLBuffer()
        }
        
        var verticies:[Vertex] = []
        
        for x in 1...LOD {
            
            let xStart = 2 * Float(x - 1) / Float(LOD) - 1
            let xEnd = 2 * Float(x) / Float(LOD) - 1
            
            for y in ...LOD {
                
                let yStart = 2 * Float(y - 1) / Float(LOD) - 1
                let yEnd = 2 * Float(y) / Float(LOD) - 1
                
                let v1 = Vector2(x: xStart, y: yStart)
                let v2 = Vector2(x: xStart, y: yEnd)
                let v3 = Vector2(x: xEnd, y: yStart)
                let v4 = Vector2(x: xEnd, y: yEnd)
                
                let h1 = self.game?.map.heightMap.evaluate(x: xStart, y: yStart)
                let h2 = self.game?.map.heightMap.evaluate(x: xStart, y: yEnd)
                let h3 = self.game?.map.heightMap.evaluate(x: xEnd, y: yStart)
                let h4 = self.game?.map.heightMap.evaluate(x: xEnd, y: yEnd)
                
                let c1 = self.sampleMapColor(at: v1)
                let c2 = self.sampleMapColor(at: v1)
                let c3 = self.sampleMapColor(at: v1)
                let c4 = self.sampleMapColor(at: v1)
                
                
                verticies.append(Vertex(pos: v1, z: h1, color: c1))
                verticies.append(Vertex(pos: v2, z: h2, color: c2))
                verticies.append(Vertex(pos: v3, z: h3, color: c3))
                verticies.append(Vertex(pos: v4, z: h4, color: c4))
                
            }
            
        }
        
        let dataSize = verticies.count * MemoryLayout.size(ofValue: verticies[0])
        guard let buffer = device.makeBuffer(bytes: verticies, length: dataSize, options: []) else { return MTLBuffer }
        
        return buffer
        
    }
    
    func sampleMapColor(at pos: Vector2) -> [Float] {
        
        let tileIndex = self.game?.map.position_to_tileIndex(pos)
        
        switch self.game?.map.tiles[tileIndex] {
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
