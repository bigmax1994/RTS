//
//  Settings.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 20.03.24.
//

import Foundation
import Metal

extension Engine {
    
    public static var pixelFormat: MTLPixelFormat = .bgra8Unorm
    public static var depthFormat: MTLPixelFormat = .depth32Float
    public static var stencilFormat: MTLPixelFormat = .invalid
    
}
