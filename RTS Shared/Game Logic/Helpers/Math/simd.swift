//
//  simd.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 04.04.24.
//

import Foundation
import simd

extension Float: Interpolatable {
    
    static var zero: Float {
        return 0
    }
    
    var magnitude: Float {
        get {
            return self
        }
    }
    
}

extension simd_float4: Interpolatable {
    
    static var zero: simd_float4 {
        return simd_float4(repeating: 0)
    }
    
    var magnitude: Float {
        get {
            return simd_length_squared(self)
        }
    }
    
    static func + (rhs: simd_float4, lhs: simd_float4) -> simd_float4 {
        return simd_float4(rhs.x + lhs.x, rhs.y + lhs.y, rhs.z + lhs.z, rhs.w + lhs.w)
    }
    
    static func - (rhs: simd_float4, lhs: simd_float4) -> simd_float4 {
        return simd_float4(rhs.x - lhs.x, rhs.y - lhs.y, rhs.z - lhs.z, rhs.w - lhs.w)
    }
    
    static func * (rhs: Float, lhs: simd_float4) -> simd_float4 {
        return simd_float4(rhs * lhs.x, rhs * lhs.y, rhs * lhs.z, rhs * lhs.w)
    }
    
    static func / (rhs: simd_float4, lhs: Float) -> simd_float4 {
        return simd_float4(rhs.x / lhs, rhs.y / lhs, rhs.z / lhs, rhs.w / lhs)
    }
    
}

extension simd_float3: Interpolatable {
    
    static var zero: simd_float3 {
        return simd_float3(repeating: 0)
    }
    
    var magnitude: Float {
        get {
            return simd_length_squared(self)
        }
    }
    
    static func + (rhs: simd_float3, lhs: simd_float3) -> simd_float3 {
        return simd_float3(rhs.x + lhs.x, rhs.y + lhs.y, rhs.z + lhs.z)
    }
    
    static func - (rhs: simd_float3, lhs: simd_float3) -> simd_float3 {
        return simd_float3(rhs.x - lhs.x, rhs.y - lhs.y, rhs.z - lhs.z)
    }
    
    static func * (rhs: Float, lhs: simd_float3) -> simd_float3 {
        return simd_float3(rhs * lhs.x, rhs * lhs.y, rhs * lhs.z)
    }
    
    static func / (rhs: simd_float3, lhs: Float) -> simd_float3 {
        return simd_float3(rhs.x / lhs, rhs.y / lhs, rhs.z / lhs)
    }
    
}

extension simd_float2: Interpolatable {
    
    static var zero: simd_float2 {
        return simd_float2(repeating: 0)
    }
    
    var magnitude: Float {
        get {
            return simd_length_squared(self)
        }
    }
    
    static func + (rhs: simd_float2, lhs: simd_float2) -> simd_float2 {
        return simd_float2(rhs.x + lhs.x, rhs.y + lhs.y)
    }
    
    static func - (rhs: simd_float2, lhs: simd_float2) -> simd_float2 {
        return simd_float2(rhs.x - lhs.x, rhs.y - lhs.y)
    }
    
    static func * (rhs: Float, lhs: simd_float2) -> simd_float2 {
        return simd_float2(rhs * lhs.x, rhs * lhs.y)
    }
    
    static func / (rhs: simd_float2, lhs: Float) -> simd_float2 {
        return simd_float2(rhs.x / lhs, rhs.y / lhs)
    }
    
}
