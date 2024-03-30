//
//  Vertex.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 09.03.24.
//

import Foundation
import simd

extension Vertex: GPUEncodable {
    
    init(pos: simd_float3, normal: simd_float3 = simd_float3(0, 0, 1), material: Material = Material(color: Color.black)) {
        self.init()
        self.pos = pos
        self.normal = normal
        self.material = material
    }
    
    init(pos: simd_float3, normal: simd_float3 = simd_float3(0, 0, 1), color: simd_float3 = Color.black) {
        let m = Material(color: color)
        self.init(pos: pos, normal: normal, material: m)
    }
    
    init(pos: Vector3, normal: Vector3 = Vector3(x: 0, y: 0, z: 1), material: Material = Material(color: Color.black)) {
        self.init()
        self.pos = pos.toSIMD()
        self.normal = normal.toSIMD()
        self.material = material
    }
    
    init(pos: Vector3, normal: Vector3 = Vector3(x: 0, y: 0, z: 1), color: simd_float3 = Color.black) {
        self.init()
        
        let m = Material(color: color)
        self.init(pos: pos, normal: normal, material: m)
        
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
        
        let points = vertexString.components(separatedBy: " ")
        let x = Float(points[1]) ?? 0
        let y = Float(points[2]) ?? 0
        let z = Float(points[3]) ?? 0
        let point = simd_float3(x, y, z)
        
        let normals = normalString.components(separatedBy: " ")
        let xN = Float(normals[1]) ?? 0
        let yN = Float(normals[2]) ?? 0
        let zN = Float(normals[3]) ?? 0
        let normal = simd_float3(xN, yN, zN)
        
        return Vertex(pos: point, normal: normal, color: Color.red)
        
    }
    
    enum VertexError: Error {
        case failedToReadFile
        case invalidFile
    }
    
}
