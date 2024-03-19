//
//  Camera.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 19.03.24.
//

import Foundation
import simd

class Camera {
    
    static let defaultPos: simd_float3 = simd_float3(0, 0, 1)
    static let defaultDir: simd_float3 = simd_float3(0, 0, -1)
    static let defaultUp: simd_float3 = simd_float3(0, 1, 0)
    
    var position: simd_float3
    var direction: simd_float3
    var up: simd_float3
    
    init() {
        self.position = Camera.defaultPos
        self.direction = Camera.defaultPos
        self.up = Camera.defaultUp
    }
    
    init(pos: Vector3, dir: Vector3, up: Vector3) {
        
        let nPos = pos.normalized()
        let nDir = dir.normalized()
        let nUp = up.normalized()
        
        self.position = simd_float3(nPos.x, nPos.y, nPos.z)
        self.direction = simd_float3(nDir.x, nDir.y, nDir.z)
        self.up = simd_float3(nUp.x, nUp.y, nUp.z)
        
    }
    
}

struct CameraTransformation {
    
    let rotationMatrix: simd_float4x4
    
    init(camera: Camera) {
        
        self.rotationMatrix = simd_float4x4(simd_float4(<#T##v0: Float##Float#>, <#T##v1: Float##Float#>, <#T##v2: Float##Float#>, <#T##v3: Float##Float#>),
                                            simd_float4(<#T##v0: Float##Float#>, <#T##v1: Float##Float#>, <#T##v2: Float##Float#>, <#T##v3: Float##Float#>),
                                            simd_float4(<#T##v0: Float##Float#>, <#T##v1: Float##Float#>, <#T##v2: Float##Float#>, <#T##v3: Float##Float#>),
                                            simd_float4(<#T##v0: Float##Float#>, <#T##v1: Float##Float#>, <#T##v2: Float##Float#>, <#T##v3: Float##Float#>))
        
    }
    
}
