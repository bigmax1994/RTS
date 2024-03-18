//
//  RTSMap_types.swift
//  RTS
//
//  Created by Magnus Saurbier on 18.03.24.
//

import Foundation

class RTSMap_square:RTSMap{
    
    init(width: Int, height: Int) {
        super.init(width: width, height: height, shape:.square)
        self.tileSize = 2/Float(max(width, height))
        self.shape = shape
        self.tiles = [TileType](repeating: .grass, count: width * height)
        for j in 0..<width{
            self.tiles[j] = TileType.forbidden
        }
        for j in (height-1)*width..<height*width{
            self.tiles[j] = TileType.forbidden
        }
        self.calculateBorderTiles()
    }

    override func tileIndex_to_position(_ index: Int) -> Vector2 {
        // (x,y) in [-1, 1]^2
        let x = Float(index % self.width) / Float(self.width) * 2 - 1
        let y = Float(index / self.width) / Float(self.height) * 2 - 1
        return Vector2(x: x, y: y)
    }
    override func position_to_tileIndex(_ position: Vector2) -> Int{
        let i = Int((position.x + 1) / 2 * Float(self.width))
        let j = Int((position.y + 1) / 2 * Float(self.height))
        return i + j * width
    }
}
