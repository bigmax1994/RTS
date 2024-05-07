//
//  World.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 26.03.24.
//

import Foundation
import Metal
import MetalKit

class World {
    
    static let renderedFrames = 3
    let inFlightSemaphore: DispatchSemaphore = DispatchSemaphore(value: renderedFrames)
    
    var animationSet:AnimationSet = AnimationSet()
    var lastUpdate:TimeInterval
    
    var light: Light
    var _lightBuffer: MTLBuffer? = nil
    
    var lightBuffer: MTLBuffer? {
        get {
            self._lightBuffer = self.createBuffer()
            return self._lightBuffer
        }
    }
    
    var camera: Camera
    
    var ui: UI?
    var objects: [Drawable]
    
    init(sunPos: Vector3 = Vector3(x: 0, y: 0, z: 1), sunColor: simd_float3 = Color.white, ambientColor: simd_float3 = Color.black, camera: Camera = Camera(), objects: [Drawable] = [], ui: UI? = nil) {

        let light = Light(mainPosition: sunPos.toSIMD(), mainColor: sunColor, ambientColor: ambientColor)
        
        self.light = light
        self.camera = camera
        self.objects = objects
        self.lastUpdate = Date().timeIntervalSince1970
        self.ui = ui
        
    }
    
    func createBuffer() -> MTLBuffer? {
        
        if let b = self._lightBuffer {
            return b
        }
        
        return Engine.Device.makeBuffer(bytes: [self.light], length: Light.bufferSize(count: 1))
        
    }
    
    func render(to view: MTKView) {
        
        let now = Date().timeIntervalSince1970
        let timeDiff = Float(now - lastUpdate)
        
        _ = inFlightSemaphore.wait(timeout: DispatchTime.distantFuture)

        if let commandBuffer = Engine.CommandQueue.makeCommandBuffer() {
            
            let semaphore = inFlightSemaphore
            commandBuffer.addCompletedHandler { (_ commandBuffer)-> Swift.Void in
                semaphore.signal()
            }
            
            self.animationSet.update(timeSinceLastUpate: timeDiff)
            
            view.clearDepth = 1
            
            /// Delay getting the currentRenderPassDescriptor until we absolutely need it to avoid
            ///   holding onto the drawable and blocking the display pipeline any longer than necessary
            let renderPassDescriptor = view.currentRenderPassDescriptor
                
            if let passDesc = renderPassDescriptor {
                
                if let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDesc) {
                    
                    if let cameraBuffer = self.camera.cameraBuffer {
                        
                        if let worldLightBuffer = self.lightBuffer {
                            
                            var inputs:[ShaderTypes : ShaderContainer] = [.CameraTransformation : .buffer(cameraBuffer), .Light : .buffer(worldLightBuffer)]
                            
                            //draw objects
                            for object in objects {
                                
                                object.draw(to: encoder, with: &inputs)
                                
                            }
                            
                            //draw ui last so it get's drawn over all others
                            if let ui = self.ui {
                                ui.draw(to: encoder, with: &inputs)
                            }
                            
                        }
                        
                    }
                    
                    encoder.endEncoding()
                    
                    if let drawable = view.currentDrawable {
                        commandBuffer.present(drawable)
                    }
                    
                }
                
            }
            
            commandBuffer.commit()
            
        }
        
        self.lastUpdate = now
        
    }
    
}
