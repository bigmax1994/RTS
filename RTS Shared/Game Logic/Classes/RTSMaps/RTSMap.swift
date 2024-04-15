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
        case forbidden
        case border
        case steep
    }
    
    enum MapShape {
        case square
        case circle
        case random
    }
    
    var tileSize: Float
    var tiles: [TileType]
    var shape: MapShape
    var borderTiles: [Int]
    let width: Int
    let height: Int
    let heightMap: RTSHeightMap
    
    var circles: [UUID : [Int]] = [:]
    
    init(width: Int, height: Int, shape: MapShape = .square) {
        
        self.width = width
        self.height = height
        self.tileSize = 2/Float(max(width, height))
        self.shape = shape

        self.tiles = []
        self.borderTiles = []
        self.heightMap = RTSHeightMap(n:2)
        
    }
    
    func setTiles() {
        for i in 0..<tiles.count{
            let pos = tileIndex_to_position(i) + Float(tileSize)/Float(2) * (Vector2.UP+Vector2.RIGHT)
            let (h, gradient) = heightMap.evaluate(v: pos)
            let height = gradient.length()-1
            //if gradient.y < -0.5 { tiles[i] = TileType.steep }
            if height < RTSGame.mapSettings.sealevel{ tiles[i] = TileType.water}
            else if height < RTSGame.mapSettings.grasstop{ tiles[i] = TileType.grass}
            else if height < RTSGame.mapSettings.mountaintop{ tiles[i] = TileType.mountain}
            else {tiles[i] = TileType.forbidden}
        }
        print("min: \(heightMap.min), max:\(heightMap.max)")
    }

    /// calculates Indices of all Tiles, that are forbidden but have a free neighbor
    func calculateBorderTiles() {
        self.borderTiles = [Int]()
        for i in 0..<tiles.count {
            if tiles[i] == .forbidden {
                var neighbors: [Int] = []
                if i%width>0{neighbors.append(i-1)}
                if i%width<width-1{neighbors.append(i+1)}
                if i/width>0{neighbors.append(i-width)}
                if i/width<height-1{neighbors.append(i+width)}
                for j in neighbors {
                    if self.tiles[j] != .border && self.tiles[j] != .forbidden {
                        borderTiles.append(i)
                        self.tiles[i] = TileType.border
                        break
                    }
                }
            }
        }
    }
    
    func tileIndex_to_position(_ index: Int) -> Vector2 {
        fatalError("not implemented!")
    }
    func position_to_tileIndex(_ position: Vector2) -> Int {
        fatalError("not implemented")
    }
    
    func reset() {
        
        self.circles = [:]
        
        tiles.replace([.closedPost], with: [.post])
        tiles.replace([.activePost], with: [.post])
        
    }
    /// checks if position is on the map
    func checkIfPositionIsInBounds(_ pos: Vector2) -> Bool {
        return pos.x >= -1 && pos.x <= 1 && pos.y >= -1 && pos.y <= 1
    }
    /// checks if position is on the map and on an active tile
    func checkIfPositionIsAllowed(_ pos: Vector2) -> Bool {
        return checkIfPositionIsInBounds(pos) && tiles[position_to_tileIndex(pos)] != .forbidden
    }
}
