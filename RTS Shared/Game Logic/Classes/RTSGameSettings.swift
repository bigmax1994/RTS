//
//  RTSGameSettings.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 08.03.24.
//

import Foundation

extension RTSGame {
    
    static let movementSpeed: Float = 0.05
    
    //Map parameters
    
    //Tile types
    static let sealevel:Float = 0.1 //height of water
    static let grasstop:Float = 0.45 //border between grass and mountain
    static let mountaintop:Float = 0.9 //border between mountain and forbidden
    //heightmap params
    static let heightLevels:[(height:Float, beginsAt:Float, sharpness:Float)] = [(0.15, -0.4, 26),(0.21, 0.1, 22), (0.51, 0.65, 12), (1.0, 0.95, 13)] //Heightlevels, which will be more present in the Heightmap (each gets a sigmoid)
    static let amplitudes:[Float]=[2.1, 1.0, 0.2, 0.08] //amplitudes of perlin layers
    static let nPosts:[Int]=[2, 7, 23, 91] //nPosts of perlin layers
    //Crater
    static let craterWidth:Float = 0.8 //width at which crater is at half height
    static let craterHeight:Float = 2 //height of crater at the top
    static let craterSharpness:Float = 6.5 //steepness of crater wall
    
}
