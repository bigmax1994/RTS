//
//  Material.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 27.03.24.
//

import Foundation
import simd

extension Material: ShaderType {
    
    static let DefaultColor: simd_float3 = simd_float3(1, 1, 1);
    static let DefaultOpacity: Float = 1;
    static let DefaultShininess: Float = 32;
    
    init(color: simd_float3 = Material.DefaultColor,
         opacity: Float = Material.DefaultOpacity,
         shininess: Float = Material.DefaultShininess) {
        
        self.init()
        
        self.color = color
        self.opacity = opacity
        self.shininess = shininess
        
    }
    
}
