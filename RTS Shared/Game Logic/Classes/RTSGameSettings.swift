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
    static var mapSettings:MapSettings = MapSettings()
    
}
struct MapSettings:Byteable {
    
    enum settingType{
        case sealevel
        case grasstop
        case mountaintop
        case heightLevels
        case amplitudes
        case nPosts
        case craterWidth
        case craterHeight
        case craterSharpness
    }
    static var byteSize: Int = 0
    
    var data:Data { get {
        var data = Data([1])
        data.append(sealevel.data)
        data.append(grasstop.data)
        data.append(mountaintop.data)
        data.append(UInt8(heightLevels.count)) //nHeightLevels
        data.append(UInt8(amplitudes.count)) //nPerlinLayers
        for level in heightLevels{
            data.append(level.0.data)
            data.append(level.1.data)
            data.append(level.2.data)
        }
        for amplitude in amplitudes {
            data.append(amplitude.data)
        }
        for nPost in nPosts {
            data.append(UInt8(nPost))
        }
        data.append(craterWidth.data)
        data.append(craterHeight.data)
        data.append(craterSharpness.data)
        return data
    }}
    //tiletypes
    var sealevel:Float = -0.75 //height of water
    var grasstop:Float = 0.0 //border between grass and mountain
    var mountaintop:Float = 0.9 //border between mountain and forbidden
    //crater
    var craterWidth:Float = 0.8 //width at which crater is at half height
    var craterHeight:Float = 5 //height of crater at the top
    var craterSharpness:Float = 6.5 //steepness of crater wall
    //heightmap params
    var heightLevels:[(height:Float, beginsAt:Float, sharpness:Float)] = [(1.0, 0.9, 1.3)]
    //[(0.25, -0.4, 15),(0.31, 0.1, 2), (0.71, 0.55, 3), (1.0, 1.10, 13)] //Heightlevels, which will be more present in the Heightmap (each gets a sigmoid)
    var amplitudes:[Float]=[2.7, 0, 0, 0] //amplitudes of perlin layers
    var nPosts:[Int]=[5, 8, 23, 191] //nPosts of perlin layers
    //Crater
    
    
    init(_ data: Data) {
        sealevel = Float(data.subdata(in: 0..<4))
        grasstop = Float(data.subdata(in: 4..<8))
        mountaintop = Float(data.subdata(in: 8..<12))
        craterWidth = Float(data.subdata(in: 12..<16))
        craterHeight = Float(data.subdata(in: 16..<20))
        craterSharpness = Float(data.subdata(in: 20..<24))
        let nHeightLevels:UInt8 = UInt8(data.subdata(in: 24..<25))
        let nPerlinLayers:UInt8 = UInt8(data.subdata(in: 25..<26))
        heightLevels = []
        var dataCursor:Int = 26
        for _ in 0..<min(nHeightLevels, 1) {
            let height:Float = Float(data.subdata(in: dataCursor..<dataCursor+4))
            dataCursor += 4
            let beginsAt:Float = Float(data.subdata(in: dataCursor..<dataCursor+4))
            dataCursor += 4
            let sharpness:Float = Float(data.subdata(in: dataCursor..<dataCursor+4))
            dataCursor += 4
            heightLevels.append((height, beginsAt, sharpness))
        }
        amplitudes = []
        for _ in 0..<min(nPerlinLayers, 4) {
            amplitudes.append(Float(data.subdata(in: dataCursor..<dataCursor+4)))
            dataCursor += 4
        }
        nPosts = []
        for _ in 0..<min(nPerlinLayers, 4) {
            nPosts.append(Int(data.subdata(in: dataCursor..<dataCursor+4)))
            dataCursor += 4
        }
    }
    init(){}
        
    
}
