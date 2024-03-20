//
//  Vertex.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 09.03.24.
//

import Foundation
import simd

struct Vertex: GPUEncodable {
    
    var pos: simd_float3
    var color: simd_float3
    
    init(pos: simd_float3, color: simd_float3) {
        self.pos = pos
        self.color = color
    }
    
    init(pos: Vector3, color: [Float]) {
        
        assert(color.count == 3, "incorrect color length")
        
        self.pos = simd_float3(pos.x, pos.y, pos.z)
        self.color = simd_float3(color)
        
    }
    
    init(pos: Vector3) {
        
        self.pos = simd_float3(pos.x, pos.y, pos.z)
        self.color = simd_float3(repeating: 0)
        
    }
    
    init(pos: Vector2) {
        
        self.pos = simd_float3(pos.x, pos.y, 0)
        self.color = simd_float3(repeating: 0)
        
    }
    
    init(x: Float, y: Float, z: Float) {
        
        self.pos = simd_float3(x, y, z)
        self.color = simd_float3(repeating: 0)
        
    }
    
    init(x: Float, y: Float) {
        
        self.pos = simd_float3(x, y, 0)
        self.color = simd_float3(repeating: 0)
        
    }
    
    init(x: Float, y: Float, color: [Float]) {
        
        self.pos = simd_float3(x, y, 0)
        self.color = simd_float3(color)
        
    }
    
    init(x: Float, y: Float, z: Float, color: [Float]) {
        
        self.pos = simd_float3(x, y, z)
        self.color = simd_float3(color)
        
    }
    
    init(x: Float, y: Float, z: Float, color: simd_float3) {
        
        self.pos = simd_float3(x, y, z)
        self.color = color
        
    }
    
    init(x: Float, y: Float, z: Float, color: Vector3) {
        
        self.pos = simd_float3(x, y, z)
        self.color = simd_float3(color.x, color.y, color.z)
        
    }
    
    init(pos: Vector3, color: Vector3) {
        
        self.pos = simd_float3(pos.x, pos.y, pos.z)
        self.color = simd_float3(color.x, color.y, color.z)
        
    }
    
    init(pos: Vector2, z: Float, color: [Float]) {
        
        self.pos = simd_float3(pos.x, pos.y, z)
        self.color = simd_float3(color)
        
    }
    
    static func readFile(_ name: String) throws -> [Vertex] {
        
        guard let url = Bundle.main.url(forResource: name, withExtension: "obj") else { throw VertexError.failedToReadFile }
        
        let content = try String(contentsOf: url)
        
        let lines = content.components(separatedBy: "\n")
        let v = lines.filter({ $0.starts(with: "v ") })
        let f = lines.filter({ $0.starts(with: "f ") })
        
        return f.reduce(into: []) { partialResult, s in
            let p = s.components(separatedBy: " ")
            for t in p {
                let i = t.components(separatedBy: "/")
                
                guard let i1 = Int(i[0]) else { continue }
                guard let i2 = Int(i[1]) else { continue }
                guard let i3 = Int(i[2]) else { continue }
                
                let fac:Float = 0.01
                
                let v1 = fac * Vertex.getVertexFromFace(v[i1 - 1])
                let v2 = fac * Vertex.getVertexFromFace(v[i2 - 1])
                let v3 = fac * Vertex.getVertexFromFace(v[i3 - 1])
                
                partialResult.append(v1)
                partialResult.append(v2)
                partialResult.append(v3)
                
            }
        }
        
    }
    
    static func getVertexFromFace(_ string: String) -> Vertex {
        
        let p = string.components(separatedBy: " ")
        let x = Float(p[1]) ?? 0
        let y = Float(p[2]) ?? 0
        let z = Float(p[3]) ?? 0
        return Vertex(x: x, y: y, z: z, color: [1,0,0])
        
    }
    
    enum VertexError: Error {
        case failedToReadFile
        case invalidFile
    }
    
    static func * (lhs: Float, rhs: Vertex) -> Vertex {
        return Vertex(x: lhs * rhs.pos.x, y: lhs * rhs.pos.y, z: lhs * rhs.pos.z, color: rhs.color)
    }
    
}
