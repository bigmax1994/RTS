//
//  World.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 26.03.24.
//

import Foundation
import Metal

class World: Drawable {
    
    var light: Light
    var _lightBuffer: MTLBuffer? = nil
    
    var lightBuffer: MTLBuffer? {
        get {
            self._lightBuffer = self.createBuffer()
            return self._lightBuffer
        }
    }
    
    var camera: Camera
    
    var objects: [Drawable]
    
    init(sunPos: Vector3 = Vector3(x: 0, y: 0, z: 1), sunColor: simd_float3 = Color.white, ambientColor: simd_float3 = Color.black, camera: Camera = Camera(), objects: [Drawable] = []) {

        let light = Light(mainPosition: sunPos.toSIMD(), mainColor: sunColor, ambientColor: ambientColor)
        
        self.light = light
        self.camera = camera
        self.objects = objects
    }
    
    func createBuffer() -> MTLBuffer? {
        
        if let b = self._lightBuffer {
            return b
        }
        
        return Engine.Device.makeBuffer(bytes: [self.light], length: Light.bufferSize(count: 1))
        
    }
    
    func draw(to encoder: MTLRenderCommandEncoder) {
        
        if let cameraBuffer = self.camera.cameraBuffer {
            
            if let worldLightBuffer = self.lightBuffer {
                
                encoder.setFragmentBuffer(cameraBuffer, offset: 0, index: Engine.CameraBufferIndex)
                encoder.setFragmentBuffer(worldLightBuffer, offset: 0, index: Engine.WorldLightBufferIndex)
                encoder.setVertexBuffer(cameraBuffer, offset: 0, index: Engine.CameraBufferIndex)
                
                for object in objects {
                    object.draw(to: encoder)
                }
                
            }
            
        }
        
    }
    
}
