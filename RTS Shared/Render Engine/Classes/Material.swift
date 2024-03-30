//
//  Material.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 28.03.24.
//

import Foundation
import simd

extension Material: GPUEncodable {
    
    init(color: simd_float3, opacity: Float = 1, shininess: Float = 8) {
        self.init()
        self.color = color
        self.opacity = opacity
        self.shininess = shininess
    }
}
