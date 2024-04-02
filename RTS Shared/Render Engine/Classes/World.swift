//
//  World.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 26.03.24.
//

import Foundation
import Metal

class World {
    
    var light: Light
    
    var _lightBuffer: MTLBuffer? = nil
    
    var lightBuffer: MTLBuffer? {
        get {
            self._lightBuffer = self.createBuffer()
            return self._lightBuffer
        }
    }
    
    init(sunPos: Vector3 = Vector3(x: 0, y: 0, z: 1), sunColor: simd_float3 = Color.white, ambientColor: simd_float3 = Color.black) {
        let light = Light(mainPosition: sunPos.toSIMD(), mainColor: sunColor, ambientColor: ambientColor)
        
        self.light = light
    }
    
    func createBuffer() -> MTLBuffer? {
        
        if let b = self._lightBuffer {
            return b
        }
        
        return Engine.Device.makeBuffer(bytes: [self.light], length: Light.bufferSize(count: 1))
        
    }
    
}
