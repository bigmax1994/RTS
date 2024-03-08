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
        case fence
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
    
    init(pixelSize: Float, maxWidth: Int, maxHeight: Int, shape: MapShape = .square) {
        
        self.pixelSize = pixelSize
        self.shape = shape
        
        if shape == .square {
            self.rowLength = [Int](repeating: maxWidth, count: maxHeight)
            self.tiles = [TileType](repeating: .grass, count: maxWidth * maxHeight)
        }else{
            fatalError("not implemented")
        }
        
    }
    
    func distributePlayer() -> Vector2 {
        
        if self.shape == .square {
            let x:Float = Float.random(in: 0.0 ... Float(rowLength[0]))
            let y:Float = Float.random(in: 0.0 ... Float(rowLength[0]))
            
            let pos = Vector2(x: x, y: y)
            return pos
        }else{
            fatalError("not implemented")
        }
        
    }
    
    func reset() {
        
        var index:Int? = tiles.firstIndex(of: .fence)
        
        while(index != nil) {
            
            tiles[index!] = .grass
            
            index = tiles.firstIndex(of: .fence)
            
        }
    }
    
}
