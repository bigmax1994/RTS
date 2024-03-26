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
    var normal: simd_float3
    var color: simd_float3
    
    init(pos: simd_float3, normal: simd_float3 = simd_float3(0, 0, 1), color: simd_float3 = simd_float3(0, 0, 0)) {
        self.pos = pos
        self.normal = normal
        self.color = color
    }
    
    init(pos: Vector3, normal: Vector3 = Vector3(x: 0, y: 0, z: 1), color: [Float] = [0,0,0]) {
        
        assert(color.count == 3, "incorrect color length")
        
        self.pos = pos.toSIMD()
        self.normal = normal.toSIMD()
        self.color = simd_float3(color)
        
    }
    
    init(pos: Vector2, normal: Vector3 = Vector3(x: 0, y: 0, z: 1), color: [Float] = [0,0,0]) {
        
        self.pos = simd_float3(pos.x, pos.y, 0)
        self.normal = simd_float3(0, 0, 1)
        self.color = simd_float3(repeating: 0)
        
    }
    
    init(x: Float, y: Float, z: Float = 0, color: [Float] = [0,0,0]) {
        
        self.init(pos: simd_float3(x, y, z), color: simd_float3(color))
        
    }
    
    init(x: Float, y: Float, z: Float = 0, normal: Vector3 = Vector3(x: 0, y: 0, z: 1), color: Vector3 = Vector3(x: 0, y: 0, z: 0)) {
        
        self.init(pos: simd_float3(x, y, z), normal: normal.toSIMD(), color: color.toSIMD())
        
    }
    
    init(x: Float, y: Float, z: Float = 0, normal: simd_float3 = simd_float3(0,0,1), color: simd_float3 = simd_float3(0,0,0)) {
        
        self.init(pos: simd_float3(x, y, z), color: simd_float3(color))
        
    }
    
    init(pos: Vector3, normal: Vector3 = Vector3(x: 0, y: 0, z: 1), color: Vector3 = Vector3(x: 0, y: 0, z: 0)) {
        
        self.init(pos: pos.toSIMD(), normal: normal.toSIMD(), color: color.toSIMD())
        
    }
    
    init(pos: Vector2, z: Float, normal: Vector3 = Vector3(x: 0, y: 0, z: 1), color: [Float] = [0,0,0]) {
        
        self.init(pos: simd_float3(pos.x, pos.y, z), normal: normal.toSIMD(), color: simd_float3(color))
        
    }
    
    static func readFile(_ name: String) throws -> [Vertex] {
        
        guard let url = Bundle.main.url(forResource: name, withExtension: "obj") else { throw VertexError.failedToReadFile }
        
        let content = try String(contentsOf: url)
        
        let lines = content.components(separatedBy: "\n")
        let v = lines.filter({ $0.starts(with: "v ") })
        let vn = lines.filter({ $0.starts(with: "vn") })
        let f = lines.filter({ $0.starts(with: "f ") })
        
        return f.reduce(into: []) { partialResult, s in
            let p = s.components(separatedBy: " ")
            
            let components1 = p[1].components(separatedBy: "/")
            let components2 = p[2].components(separatedBy: "/")
            let components3 = p[3].components(separatedBy: "/")
            
            guard let pointIndex1 = Int(components1[0]) else { return }
            guard let pointIndex2 = Int(components2[0]) else { return }
            guard let pointIndex3 = Int(components3[0]) else { return }
            
            guard let normalIndex1 = Int(components1[1]) else { return }
            guard let normalIndex2 = Int(components2[1]) else { return }
            guard let normalIndex3 = Int(components3[1]) else { return }
                
            let v1 = Vertex.getVertexFrom(v[pointIndex1 - 1], normal: vn[normalIndex1 - 1])
            let v2 = Vertex.getVertexFrom(v[pointIndex2 - 1], normal: vn[normalIndex2 - 1])
            let v3 = Vertex.getVertexFrom(v[pointIndex3 - 1], normal: vn[normalIndex3 - 1])
            
            partialResult.append(v1)
            partialResult.append(v2)
            partialResult.append(v3)
            
        }
        
    }
    
    static func getVertexFrom(_ vertexString: String, normal normalString: String) -> Vertex {
        
        let p = vertexString.components(separatedBy: " ")
        let x = Float(p[1]) ?? 0
        let y = Float(p[2]) ?? 0
        let z = Float(p[3]) ?? 0
        let point = simd_float3(x, y, z)
        
        let coords = normalString.components(separatedBy: " ")
        let xN = Float(p[1]) ?? 0
        let yN = Float(p[2]) ?? 0
        let zN = Float(p[3]) ?? 0
        let normal = simd_float3(xN, yN, zN)
        
        return Vertex(pos: point, normal: normal, color: simd_float3(1, 0, 0))
        
    }
    
    enum VertexError: Error {
        case failedToReadFile
        case invalidFile
    }
    
    static func * (lhs: Float, rhs: Vertex) -> Vertex {
        return Vertex(x: lhs * rhs.pos.x, y: lhs * rhs.pos.y, z: lhs * rhs.pos.z, normal: rhs.normal, color: rhs.color)
    }
    
}
