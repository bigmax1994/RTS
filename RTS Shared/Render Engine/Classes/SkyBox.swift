//
//  SkyBox.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 19.03.24.
//

import Foundation
import Metal

class Skybox: Object {
    
    override func moveBy(_ v: Vector3) {
        return
    }
    override func moveTo(_ v: Vector3) {
        return
    }
    
    override func rotateBy(_ m: Matrix) {
        return
    }
    
    override func rotateTo(_ m: Matrix) {
        return
    }
    
    override init?(verticies: [Vertex], at pos: Vector3, rotated: Matrix, device: any MTLDevice, label: String? = nil) {
        super.init(verticies: verticies, at: Vector3(), rotated: Matrix.Identity(4), device: device, label: label)
    }
    
    init?(color: Vector3, device: any MTLDevice) {
        
        let v1 = Vertex(x: -1, y: -1, z: -1, color: color)
        let v2 = Vertex(x: -1, y: -1, z: 1, color: color)
        let v3 = Vertex(x: -1, y: 1, z: -1, color: color)
        let v4 = Vertex(x: -1, y: 1, z: 1, color: color)
        let v5 = Vertex(x: 1, y: -1, z: -1, color: color)
        let v6 = Vertex(x: 1, y: -1, z: 1, color: color)
        let v7 = Vertex(x: 1, y: 1, z: -1, color: color)
        let v8 = Vertex(x: 1, y: 1, z: 1, color: color)
        
        let v = [v1, v2, v4,
                 v1, v3, v4,
                 v1, v2, v6,
                 v1, v5, v6,
                 v1, v5, v7,
                 v1, v3, v7,
                 v8, v7, v6,
                 v8, v3, v4,
                 v8, v2, v4,
                 v5, v6, v7,
                 v3, v4, v7,
                 v2, v6, v8]
        
        super.init(verticies: v, at: Vector3(), rotated: Matrix.Identity(4), device: device, label: "Skybox")
        
    }
    
}
