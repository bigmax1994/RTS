//
//  RTSMap.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 05.03.24.
//

import Foundation

class RTSMap {
    
    enum TileType {
        case grass
        case mountain
        case water
        case post
        case activePost
        case closedPost
    }
    
    enum MapShape {
        case square
        case circle
        case random
    }
    
    var pixelSize: Float
    var tiles: [TileType]
    var rowLength: [Int]
    var shape: MapShape
    
    var circles: [UUID : [Int]] = [:]
    
    init(pixelSize: Float, maxWidth: Int, maxHeight: Int, shape: MapShape = .square) {
        
        self.pixelSize = pixelSize
        self.shape = shape
        
        switch shape {
        case .square:
            
            self.rowLength = [Int](repeating: maxWidth, count: maxHeight)
            self.tiles = [TileType](repeating: .grass, count: maxWidth * maxHeight)
            
        default:
            fatalError("not implemented")
        }
        
    }
    
    func distributePlayer() -> Vector2 {
        
        switch shape {
        case .square:
            
            let x:Float = Float.random(in: 0.0 ... (Float(rowLength[0]) * pixelSize))
            let y:Float = Float.random(in: 0.0 ... (Float(rowLength.count) * pixelSize))
            
            let pos = Vector2(x: x, y: y)
            return pos
                
        default:
            fatalError("not implemented")
        }
        
    }
    
    func reset() {
        
        self.circles = [:]
        
        tiles.replace([.closedPost], with: [.post])
        tiles.replace([.activePost], with: [.post])
        
    }
    
    func checkIfPositionIsInBounds(_ pos: Vector2) -> Bool {
        
        switch shape {
        case .square:
            
            return pos.x >= 0 && 
                pos.x <= Float(rowLength[0]) * pixelSize &&
                pos.y >= 0 &&
                pos.x <= Float(rowLength.count) * pixelSize
                
        default:
            fatalError("not implemented")
        }
        
    }
    
}
