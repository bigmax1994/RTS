//
//  RTSGameSettings.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 08.03.24.
//

import Foundation

extension RTSGame {
    
    static let movementSpeed: Float = 0.02
    
    //Map parameters
    
    //Tile types
    static let mapSettings: MapSettings = MapSettings()
    
}

struct MapSettings: Byteable {
    static var byteSize: Int = 0
    
    var data: Data {
        get {
            return Data()
        }
    }
    
    init() {}
    
    init(_ data: Data) {
        
    }
    
    let sealevel:Float = -0.75 //height of water
    let grasstop:Float = 0.0 //border between grass and mountain
    let mountaintop:Float = 0.9 //border between mountain and forbidden
    //heightmap params
    let heightLevels:[(height:Float, beginsAt:Float, sharpness:Float)] = [(1.0, 0.9, 1.3)]
    //[(0.25, -0.4, 15),(0.31, 0.1, 2), (0.71, 0.55, 3), (1.0, 1.10, 13)] //Heightlevels, which will be more present in the Heightmap (each gets a sigmoid)
    let amplitudes:[Float]=[2.7, 0.8, 0.3, 0.1] //amplitudes of perlin layers
    let nPosts:[Int]=[5, 8, 23, 191] //nPosts of perlin layers
    //Crater
    let craterWidth:Float = 0.8 //width at which crater is at half height
    let craterHeight:Float = 5 //height of crater at the top
    let craterSharpness:Float = 6.5 //steepness of crater wall
}
