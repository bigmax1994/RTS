//
//  Object.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 19.03.24.
//

import Foundation
import Metal

class Object {
    
    var verticies: MTLBuffer
    var vertexCount: Int
     
    var rotation: Matrix
    var position: Vector3
    
    convenience init?(verticies: [Vertex], device: MTLDevice) {
        
        self.init(verticies: verticies, at: Vector3(), device: device)
        
    }
    
    convenience init?(verticies: [Vertex], at pos: Vector3, device: MTLDevice) {
        
        self.init(verticies: verticies, at: pos, rotated: Matrix.Identity(3), device: device)
        
    }
    
    convenience init?(verticies: [Vertex], at pos: Vector2, device: MTLDevice) {
        
        self.init(verticies: verticies, at: Vector3(x: pos.x, y: pos.y, z: 0), device: device)
        
    }
    
    init?(verticies: [Vertex], at pos: Vector3, rotated: Matrix, device: MTLDevice) {
        
        assert(verticies.count > 0, "empty Object")
        assert(rotated.columns == rotated.rows && rotated.rows == 3, "")
        
        self.vertexCount = verticies.count
        
        let dataSize = self.vertexCount * MemoryLayout.size(ofValue: verticies[0])
        
        if let buffer = device.makeBuffer(bytes: verticies, length: dataSize) {
            self.verticies = buffer
        }else{
            return nil
        }
        
        self.rotation = rotated
        self.position = pos
        
    }
    
    func moveTo(_ pos: Vector3) {
        self.position = pos
    }
    
    func moveBy(_ v: Vector3) {
        self.position = self.position + v
    }
    
    func rotateTo(_ m: Matrix) {
        
        
        
    }
    
}
