//
//  GPUEncodable.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 20.03.24.
//

import Foundation
import Metal

enum ShaderContainer {
    case buffer(MTLBuffer)
    case texture([MTLTexture])
}

protocol ShaderType { }

extension ShaderType {
    
    static func bufferSize(count elements: Int) -> Int {
        return MemoryLayout<Self>.size * elements
    }
    
    static func bufferStride(count elements: Int) -> Int {
        return MemoryLayout<Self>.stride * elements
    }
    
}

internal enum ShaderTypes: CaseIterable {
    case Material
    case TextureMaterial
    case Vertex
    case TextureVertex
    case Transformation
    case CameraTransformation
    case Light
    case Texture
}
