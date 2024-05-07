//
//  Color.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 28.03.24.
//

import Foundation
import simd

struct Color {
    
    static var red: simd_float3 {
        get {
            return simd_float3(1, 0, 0)
        }
    }
    static var blue: simd_float3 {
        get {
            return simd_float3(0, 0, 1)
        }
    }
    static var green: simd_float3 {
        get {
            return simd_float3(0, 1, 0)
        }
    }
    
    static var brown: simd_float3 {
        get {
            return simd_float3(0.7631, 0.4432, 0.1306)
        }
    }
    
    static var grey: simd_float3 {
        get {
            return simd_float3(0.4, 0.4, 0.4)
        }
    }
    
    static var white: simd_float3 {
        get {
            return simd_float3(1, 1, 1)
        }
    }
    
    static var black: simd_float3 {
        get {
            return simd_float3(0, 0, 0)
        }
    }
    
    static var lightBlue: simd_float3 {
        get {
            return simd_float3(38.0 / 255.0, 194.0 / 255.0, 220.0 / 255.0)
        }
    }
}
