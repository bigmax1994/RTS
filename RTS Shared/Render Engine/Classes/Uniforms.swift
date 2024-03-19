//
//  Uniforms.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 19.03.24.
//

import Foundation
import simd

struct Uniforms {
    
    var m: simd_float4x4
    var p: simd_float4
    
    init(matrix: Matrix, position: Vector3) {
        m = simd_float4x4(simd_float4(matrix[0,0], matrix[0,1], matrix[0,2], matrix[0,3]),
                          simd_float4(matrix[1,0], matrix[1,1], matrix[1,2], matrix[1,3]),
                          simd_float4(matrix[2,0], matrix[2,1], matrix[2,2], matrix[2,3]),
                          simd_float4(matrix[3,0], matrix[3,1], matrix[3,2], matrix[3,3]))
        p = simd_float4(position.x, position.y, position.z, 1)
    }
    
}
