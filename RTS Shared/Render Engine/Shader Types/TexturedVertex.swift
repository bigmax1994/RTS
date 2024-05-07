//
//  TexturedVertex.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 07.04.24.
//

import Foundation

extension TexturedVertex: ShaderType {
    
    init(pos: simd_float3, normal: simd_float3 = simd_float3(0, 0, 1), material: TexturedMaterial = TexturedMaterial()) {
        self.init()
        self.pos = pos
        self.normal = normal
        self.material = material
    }
    
    init(pos: Vector3, normal: Vector3 = Vector3(x: 0, y: 0, z: 1), material: TexturedMaterial = TexturedMaterial()) {
        self.init()
        self.pos = pos.toSIMD()
        self.normal = normal.toSIMD()
        self.material = material
    }
    
    static func makeQuad(in rect: CGRect, textureSize: CGRect) -> [TexturedVertex] {
        
        let minX = Float(rect.minX)
        let maxX = Float(rect.maxX)
        let minY = Float(rect.minY)
        let maxY = Float(rect.maxY)
        
        return [TexturedVertex(pos: simd_float3(minX, minY, 1), normal: simd_float3(0, 0, -1), material: TexturedMaterial(texturePosition: simd_float2(minX, minY), opacity: 1, shininess: 0)),
                TexturedVertex(pos: simd_float3(minX, maxY, 1), normal: simd_float3(0, 0, -1), material: TexturedMaterial(texturePosition: simd_float2(minX, maxY), opacity: 1, shininess: 0)),
                TexturedVertex(pos: simd_float3(maxX, minY, 1), normal: simd_float3(0, 0, -1), material: TexturedMaterial(texturePosition: simd_float2(maxX, minY), opacity: 1, shininess: 0)),
                TexturedVertex(pos: simd_float3(minX, maxY, 1), normal: simd_float3(0, 0, -1), material: TexturedMaterial(texturePosition: simd_float2(minX, maxY), opacity: 1, shininess: 0)),
                TexturedVertex(pos: simd_float3(maxX, minY, 1), normal: simd_float3(0, 0, -1), material: TexturedMaterial(texturePosition: simd_float2(maxX, minY), opacity: 1, shininess: 0)),
                TexturedVertex(pos: simd_float3(maxX, maxY, 1), normal: simd_float3(0, 0, -1), material: TexturedMaterial(texturePosition: simd_float2(maxX, maxY), opacity: 1, shininess: 0))]
        
    }
    
    static func makeStripQuad(in rect: CGRect, textureSize: CGRect) -> [TexturedVertex] {
        
        let minX = Float(rect.minX)
        let maxX = Float(rect.maxX)
        let minY = Float(rect.minY)
        let maxY = Float(rect.maxY)
        
        return [TexturedVertex(pos: simd_float3(minX, minY, 1), normal: simd_float3(0, 0, -1), material: TexturedMaterial(texturePosition: simd_float2(minX, minY), opacity: 1, shininess: 0)),
                TexturedVertex(pos: simd_float3(minX, maxY, 1), normal: simd_float3(0, 0, -1), material: TexturedMaterial(texturePosition: simd_float2(minX, maxY), opacity: 1, shininess: 0)),
                TexturedVertex(pos: simd_float3(maxX, minY, 1), normal: simd_float3(0, 0, -1), material: TexturedMaterial(texturePosition: simd_float2(maxX, minY), opacity: 1, shininess: 0)),
                TexturedVertex(pos: simd_float3(maxX, maxY, 1), normal: simd_float3(0, 0, -1), material: TexturedMaterial(texturePosition: simd_float2(maxX, maxY), opacity: 1, shininess: 0))]
        
    }
    
    enum VertexError: Error {
        case failedToReadFile
        case invalidFile
    }
    
}
