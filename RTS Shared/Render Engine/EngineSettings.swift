//
//  Settings.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 20.03.24.
//

import Foundation
import Metal

class EngineSettings {
    
    public static var pixelFormat: MTLPixelFormat = .bgra8Unorm
    public static var depthFormat: MTLPixelFormat = .invalid
    public static var stencilFormat: MTLPixelFormat = .invalid
    
    internal static let CameraBufferIndex: Int = 0
    internal static let DataBufferIndex: Int = 1
    
}
