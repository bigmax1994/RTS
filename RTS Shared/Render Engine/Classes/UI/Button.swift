//
//  Button.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 03.04.24.
//

import Foundation
import Metal

class Button: Object, Clickable {
    
    var rect: (Vector2, Vector2)
    
    var text: Text
    
    var onClick: () -> Void
    
    func isInside(_ pos: Vector2) -> Bool {
        
        if pos.x < rect.0.x || pos.x > rect.1.x {
            return false
        }
        if pos.y < rect.0.y || pos.y > rect.1.y {
            return false
        }
        
        return true
        
    }
    
    func clickAnimation() -> Animatable {
        
        let completion: (simd_float2) -> Void = { f in
            self.transformation.s.x = f.x
            self.transformation.s.y = f.y
        }
        
        let changes:(simd_float2, simd_float2, (simd_float2) -> Void) = (simd_float2(repeating: 1), simd_float2(repeating: 0.8), completion)
        return Animation(duration: 0.2, change: changes)
    }
    
    init?(onClick: @escaping () -> Void, pos: Vector2, size: Vector2, color: simd_float3, text: String = "") {
        
        let material = Material(color: color, opacity: 1, shininess: 0)
        self.onClick = onClick
        
        self.rect = (pos, pos + size)
        
        let textRect = CGRect(x: CGFloat(pos.x), y: CGFloat(pos.y), width: CGFloat(size.x), height: CGFloat(size.y))
        self.text = Text(text, frame: textRect)
        
        let minX = pos.x
        let minY = pos.y
        let maxX = pos.x + size.x
        let maxY = pos.y + size.y
        
        let verticies = [Vertex(pos: simd_float3(minX, minY, 0.5), normal: simd_float3(0, 0, -1), material: material),
                         Vertex(pos: simd_float3(minX, maxY, 0.5), normal: simd_float3(0, 0, -1), material: material),
                         Vertex(pos: simd_float3(maxX, minY, 0.5), normal: simd_float3(0, 0, -1), material: material),
                         Vertex(pos: simd_float3(minX, maxY, 0.5), normal: simd_float3(0, 0, -1), material: material),
                         Vertex(pos: simd_float3(maxX, minY, 0.5), normal: simd_float3(0, 0, -1), material: material),
                         Vertex(pos: simd_float3(maxX, maxY, 0.5), normal: simd_float3(0, 0, -1), material: material)]
        
        //let center2 = pos + (size / 2)
        //let center = Vector3(x: center2.x, y: center2.y, z: 1)
        
        super.init(verticies: verticies, pipelineState: .plane, stencilState: .always)
        
    }
    
    override func draw(to encoder: any MTLRenderCommandEncoder, with inputs: inout [ShaderTypes : ShaderContainer]) {
        /*encoder.pushDebugGroup("Encoder for \(self.getName())")
        
        if self.transformationBuffer == nil || self.vertexBuffer == nil {
            self.createBuffers()
        }
        guard let transformBuffer = self.transformationBuffer else {
            NSLog("Could Not Create Transformation Buffer")
            return
        }
        inputs.updateValue(.buffer(transformBuffer), forKey: .Transformation)
        
        guard let vertexBuffer = self.vertexBuffer else {
            NSLog("Could Not Create Vertex Buffer")
            return
        }*/
        
        super.draw(to: encoder, with: &inputs)
        self.text.draw(to: encoder, with: &inputs)
        //inputs.updateValue(.buffer(vertexBuffer), forKey: .Vertex)
        //Engine.encodeRenderCommand(inputs: inputs, pipeline: self.pipelineState, stencil: self.stencilState, encoder: encoder)
    }
    
}
