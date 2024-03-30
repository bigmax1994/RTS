//
//  Object.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 19.03.24.
//

import Foundation
import Metal
import MetalKit

class Object: Drawable {
    
    var pipelineState: PipelineState
    var stencilState: StencilState
    
    let label:String?
    
    private var transformation: Transformation
    
    var verticies: [Vertex]
    
    private var transformationBuffer: MTLBuffer? = nil
    private var vertexBuffer: MTLBuffer? = nil
    
    init?(verticies: [Vertex], at pos: Vector3 = Vector3(), rotated: Matrix = Matrix.Identity(3), scale: Vector3 = Vector3(x: 1, y: 1, z: 1), pipelineState: PipelineState = PipelineState.getDefault(), stencilState: StencilState = StencilState.getDefault(), label: String? = nil) {
        
        assert(verticies.count > 0, "empty Object")
        assert(rotated.isOrthogonal && rotated.rows == 3, "matrix not Orthogonal")
        
        self.pipelineState = pipelineState
        self.stencilState = stencilState
        
        self.verticies = verticies
        
        self.transformation = Transformation(matrix: rotated, position: pos, size: scale)
        
        self.label = label
        
        self.createBuffers()
        
    }
    
    func moveTo(_ pos: Vector3) {
        self.transformation.moveTo(pos)
        self.createTrafoBuffer()
    }
    
    func moveBy(_ v: Vector3) {
        self.transformation.moveBy(v)
        self.createTrafoBuffer()
    }
    
    func rotateTo(_ m: Matrix) {
        self.transformation.rotateTo(m)
        self.createTrafoBuffer()
    }
    
    func rotateBy(_ m: Matrix) {
        self.transformation.rotateBy(m)
        self.createTrafoBuffer()
    }
    
    func scaleTo(_ s: Vector3) {
        self.transformation.scaleTo(s)
        self.createTrafoBuffer()
    }
    
    func scaleTo(_ s: Float) {
        self.transformation.scaleTo(s)
        self.createTrafoBuffer()
    }
    
    func scaleBy(_ s: Vector3) {
        self.transformation.scaleBy(s)
        self.createTrafoBuffer()
    }
    
    func scaleBy(_ s: Float) {
        self.transformation.scaleBy(s)
        self.createTrafoBuffer()
    }
    
    var position: Vector3 {
        get {
            return Vector3(self.transformation.p)
        }
    }
    
    func createBuffers() {
        
        self.vertexBuffer = Engine.Device.makeBuffer(bytes: self.verticies, length: Vertex.bufferSize(count: self.verticies.count))
        self.createTrafoBuffer()
        
    }
    
    func createTrafoBuffer() {
        self.transformationBuffer = Engine.Device.makeBuffer(bytes: [self.transformation], length: Transformation.bufferSize(count: 1))
    }
    
    func draw(to encoder: MTLRenderCommandEncoder) {
        
        encoder.pushDebugGroup("Encoder for \(self.getName())")
        
        guard let pipelineState = self.pipelineState.getMTLState() else {
            NSLog("Failed to get pipeline State")
            return
        }
        encoder.setRenderPipelineState(pipelineState)
        
        guard let stencilState = self.stencilState.getMTLState() else {
            NSLog("Failed to get stencil State")
            return
        }
        encoder.setDepthStencilState(stencilState)
        
        if self.transformationBuffer == nil {
            self.createBuffers()
        }
        guard let transformBuffer = self.transformationBuffer else {
            NSLog("Could Not Create Transformation Buffer")
            return
        }
        
        encoder.setVertexBuffer(transformBuffer, offset: 0, index: EngineSettings.TransformationBufferIndex)
        encoder.setVertexBuffer(self.vertexBuffer, offset: 0, index: EngineSettings.DataBufferIndex)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: self.verticies.count)
        
        encoder.popDebugGroup()
        
    }
    
    func getName() -> String {
        
        guard let name = self.label else {
            return "N/A"
        }
        return name
        
    }
    
    public static func MakeCube(color: simd_float3, label: String? = nil) -> Object? {
        
        let v1 = Vertex(pos: Vector3(x: -1, y: -1, z: -1), color: color)
        let v2 = Vertex(pos: Vector3(x: -1, y: -1, z: 1), color: color)
        let v3 = Vertex(pos: Vector3(x: -1, y: 1, z: -1), color: color)
        let v4 = Vertex(pos: Vector3(x: -1, y: 1, z: 1), color: color)
        let v5 = Vertex(pos: Vector3(x: 1, y: -1, z: -1), color: color)
        let v6 = Vertex(pos: Vector3(x: 1, y: -1, z: 1), color: color)
        let v7 = Vertex(pos: Vector3(x: 1, y: 1, z: -1), color: color)
        let v8 = Vertex(pos: Vector3(x: 1, y: 1, z: 1), color: color)
        
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
        
        return Object(verticies: v, pipelineState: .basic, label: label)
        
    }
    
}
