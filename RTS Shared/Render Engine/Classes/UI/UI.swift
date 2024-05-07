//
//  UI.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 03.04.24.
//

import Foundation
import Metal
import MetalKit

class UI: Drawable, UIDelegate {
    
    var animations: AnimationSet = AnimationSet()
    
    var uiObjects: [UIObject]
    
    lazy var lightBuffer: MTLBuffer? = {
       
        var light = Light(mainPosition: simd_float3(0, 0, -1), mainColor: Color.white, ambientColor: Color.white)
        return Engine.Device.makeBuffer(bytes: &light, length: Light.bufferSize(count: 1))
        
    }()
    
    init(objects: [UIObject] = []) {
        
        self.uiObjects = objects
        
    }
    
    func clicked(at pos: Vector2) {
        for object in self.uiObjects {
            if let clickable = object as? Clickable {
                if clickable.isInside(pos) {
                    self.animations.animations.append(clickable.clickAnimation())
                    clickable.onClick()
                    return
                }
            }
        }
    }
    
    func moved(to pos: Vector2) {
        return
    }
    
    func draw(to encoder: any MTLRenderCommandEncoder, with inputs: inout [ShaderTypes : ShaderContainer]) {
        
        guard let light = self.lightBuffer else {
            NSLog("failed to make Light buffer for UI")
            return
        }
        
        inputs.updateValue(.buffer(light), forKey: .Light)
        
        for object in self.uiObjects {
            object.draw(to: encoder, with: &inputs)
        }
        
    }
    
}
