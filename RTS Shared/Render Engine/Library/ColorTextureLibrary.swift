//
//  ColorTextureLibrary.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 07.04.24.
//

import Foundation
import simd
import Metal
import CoreImage
import MetalKit

struct ColorTextureLibrary {
    
    @available(*, unavailable) private init() {}
    
    static private var textures: [simd_float3 : MTLBuffer] = [:]
    static private var textureLoader: MTKTextureLoader!
    
    static func Boot() {
        
        self.textureLoader = MTKTextureLoader(device: Engine.Device)
        
    }
    
    static internal func getTexture(_ color: simd_float3) -> MTLBuffer? {
        
        if let texture = self.textures[color] {
            return texture
        }
        
        let img = CIImage(color: CIColor(red: CGFloat(color.x), green: CGFloat(color.y), blue: CGFloat(color.z))).cropped(to: CGRect(x: 0, y: 0, width: 1, height: 1))
        guard let cgImage = img.cgImage else {
            NSLog("Failed to get CGImage for color \(color)")
            return nil
        }
        
        do {
            let texture = try ColorTextureLibrary.textureLoader.newTexture(cgImage: cgImage)
            guard let buffer = texture.buffer else {
                NSLog("failed to create buffer for color texture")
                return nil
            }
            self.textures.updateValue(buffer, forKey: color)
            return buffer
        }catch {
            NSLog("Failed to create color texture")
            return nil
        }
        
    }
    
}
