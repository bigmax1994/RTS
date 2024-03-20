//
//  Drawable.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 20.03.24.
//

import Foundation
import Metal

protocol Drawable {
    
    func draw(to encoder: MTLRenderCommandEncoder)
    
}
