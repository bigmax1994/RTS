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
    
    var circles: [UUID : [Int]] = [:]
    
    init(width: Int, height: Int, shape: MapShape = .square) {
        
        self.width = width
        self.height = height
        self.tileSize = 2/Float(max(width, height))
        self.shape = shape

        self.tiles = []
        self.borderTiles = []
        
    }

    /// calculates Indices of all Tiles, that are forbidden but have a free neighbor
    func calculateBorderTiles() {
        self.borderTiles = [Int]()
        for i in 0..<tiles.count {
            if tiles[i] == .forbidden {
                let pos = tileIndex_to_position(i) + Vector2(x:tileSize/2, y:tileSize/2)
                let (angle, range) = {switch self.shape {
                    case .square:
                        return (Float.pi/2, 0..<4)
                    case .circle:
                        return (Float.pi/6, 0..<6)
                    default:
                        return (1, 0..<1)
                }}()
                for j in range {
                    let neighborIndex = position_to_tileIndex(pos + Vector2(angle: angle * Float(j), length: tileSize))
                    //print("\(i) checking \(neighborIndex) at angle \(angle * Float(j)) to \(Vector2(angle: angle * Float(j), length: tileSize))")
                    if 0<=neighborIndex && neighborIndex < self.tiles.count && self.tiles[neighborIndex] != .forbidden {
                        borderTiles.append(i)
                        break
                    }
                }
            }
        }
    }
    
    func tileIndex_to_position(_ index: Int) -> Vector2 {
        fatalError("not implemented!")
    }
    func position_to_tileIndex(_ position: Vector2) -> Int{
        fatalError("not implemented")
    }
    
    /// chooses random starting position for a player
    func distributePlayer(target: Vector2, deviation: Float = 0.1) -> Vector2 {
        // angle a in [0, 2pi]
        let a = Float.random(in: 0..<2 * Float.pi)
        // distance d in [0, 1]
        let d = Float.random(in: 0..<1)
        // (x,y) in [-1, 1]^2
        var v = Vector2(x: cos(a) * d, y: sin(a) * d)
        while !checkIfPositionIsAllowed(target + deviation * v) {
            v = 0.5*v
        }
        return target + deviation * v
    }
    ///spread out the players on the map
    func distributePlayersStep() {
        
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
