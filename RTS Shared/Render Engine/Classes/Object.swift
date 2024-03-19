//
//  Object.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 19.03.24.
//

import Foundation
import Metal
import MetalKit

class Object {
    
    let label:String?
    
    var verticies: MTLBuffer
    var vertexCount: Int
     
    var rotation: Matrix
    var position: Vector3
    
    var uniforms: MTLBuffer!
    
    convenience init?(verticies: [Vertex], device: MTLDevice, label: String? = nil) {
        
        self.init(verticies: verticies, at: Vector3(), device: device, label: label)
        
    }
    
    convenience init?(verticies: [Vertex], at pos: Vector3, device: MTLDevice, label: String? = nil) {
        
        self.init(verticies: verticies, at: pos, rotated: Matrix.Identity(4), device: device, label: label)
        
    }
    
    convenience init?(verticies: [Vertex], at pos: Vector2, device: MTLDevice, label: String? = nil) {
        
        self.init(verticies: verticies, at: Vector3(x: pos.x, y: pos.y, z: 0), device: device, label: label)
        
    }
    
    init?(verticies: [Vertex], at pos: Vector3, rotated: Matrix, device: MTLDevice, label: String? = nil) {
        
        assert(verticies.count > 0, "empty Object")
        assert(rotated.isOrthogonal && rotated.rows == 4, "matrix not Orthogonal")
        
        self.vertexCount = verticies.count
        
        let dataSize = self.vertexCount * MemoryLayout.size(ofValue: verticies[0])
        
        if let buffer = device.makeBuffer(bytes: verticies, length: dataSize) {
            self.verticies = buffer
        }else{
            return nil
        }
        
        self.rotation = rotated
        self.position = pos
        
        self.label = label
        
        self.updateUniforms(device)
        
    }
    
    func moveTo(_ pos: Vector3) {
        self.position = pos
    }
    
    func moveBy(_ v: Vector3) {
        self.position = self.position + v
    }
    
    func rotateTo(_ m: Matrix) {
        assert(m.isOrthogonal && m.rows == 4, "matrix not Orthogonal")
        self.rotation = m
    }
    
    func rotateBy(_ m: Matrix) {
        assert(m.isOrthogonal && m.rows == 4, "matrix not Orthogonal")
        self.rotation = Matrix.fastDotAdd(A: self.rotation, B: m)
    }
    
    func updateUniforms(_ device: MTLDevice) {
        
        let u = Uniforms(matrix: self.rotation, position: self.position)
        
        if let buffer = device.makeBuffer(bytes: [u], length: MemoryLayout.size(ofValue: u)) {
            self.uniforms = buffer
        }
        
    }
    
    func draw(_ view: MTKView, cmdBuffer: MTLCommandBuffer, pipelineState: MTLRenderPipelineState, device: MTLDevice, cameraBuffer: MTLBuffer) {
        
        guard let desc = view.currentRenderPassDescriptor else {
            return
        }
        
        guard let encoder = cmdBuffer.makeRenderCommandEncoder(descriptor: desc) else {
            return
        }
        encoder.label = "Encoder for \(self.label ?? "N/A")"
        
        encoder.setVertexBuffer(cameraBuffer, offset: 0, index: 0)
        
        self.updateUniforms(device)
        encoder.setVertexBuffer(self.uniforms, offset: 0, index: 1)
        
        encoder.setRenderPipelineState(pipelineState)
        encoder.setVertexBuffer(self.verticies, offset: 0, index: 2)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: self.vertexCount)
        
        encoder.endEncoding()
        
    }
    
}
