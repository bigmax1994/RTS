//
//  WorldSettings.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 26.03.24.
//

import Foundation
import Metal

struct WorldSettings: GPUEncodable {
    
    let sunPosition: simd_float3
    let sunColor: simd_float3
    
    init(sunPos: simd_float3 = simd_float3(0, 0, 1), sunColor: simd_float3 = simd_float3(1, 1, 1)) {
        self.sunPosition = normalize(sunPos)
        self.sunColor = sunColor
    }
    
    init(sunPos: Vector3 = Vector3(x: 0, y: 0, z: 1), sunColor: Vector3 = Vector3(x: 1, y: 1, z: 1)) {
        self.init(sunPos: sunPos.toSIMD(), sunColor: sunColor.toSIMD())
    }
    
}
