//
//  Engine.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 20.03.24.
//

import Foundation
import Metal
import MetalKit
import CoreImage

struct Engine {
    
    @available(*, unavailable) private init() {}
    
    static var Device: MTLDevice!
    static var CommandQueue: MTLCommandQueue!
    static var CIContext: CIContext!
    
    public static func Boot(to view: MTKView) {
        
        //Boot Metal
        guard let device = MTLCreateSystemDefaultDevice() else {
            NSLog("Metal unavailable")
            return
        }
        Engine.Device = device
        
        view.device = Engine.Device
        view.depthStencilPixelFormat = Engine.depthFormat
        view.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        view.colorPixelFormat = Engine.pixelFormat
        view.colorspace = view.window?.colorSpace?.cgColorSpace
        
        //Create Command Queue
        guard let queue = Engine.Device.makeCommandQueue() else {
            NSLog("Command Queue unavailable")
            return
        }
        Engine.CommandQueue = queue
        
        Engine.CIContext = CoreImage.CIContext(mtlDevice: Engine.Device)
        
        //Boot Libraries
        FunctionLibrary.Boot()
        PipelineStateLibrary.Boot()
        StencilStateLibrary.Boot()
        ComputeStateLibrary.Boot()
        
    }
    
    static func encodeRenderCommand(inputs: [ShaderTypes: ShaderContainer], pipeline: PipelineState, stencil: StencilState, encoder: MTLRenderCommandEncoder) {
        
        guard let pipelineState = pipeline.getMTLState() else {
            NSLog("Failed to get pipeline State")
            return
        }
        encoder.setRenderPipelineState(pipelineState)
        
        guard let stencilState = stencil.getMTLState() else {
            NSLog("Failed to get stencil State")
            return
        }
        encoder.setDepthStencilState(stencilState)
        
        //set vertex buffers
        for (i, vInput) in pipeline.getVertexFunction().getInputs().enumerated() {
            
            guard let inputBuffer = inputs[vInput] else {
                NSLog("Did not submit input of type \(vInput)")
                return
            }
            
            switch inputBuffer {
            case .buffer(let buffer):
                encoder.setVertexBuffer(buffer, offset: 0, index: i)
            default:
                NSLog("passed texture as buffer")
                continue
            }
            
        }
        
        //set fragment buffers
        for (i, vInput) in pipeline.getFragmentFunction().getInputs().enumerated() {
            
            guard let inputBuffer = inputs[vInput] else {
                NSLog("Did not submit input of type \(vInput)")
                return
            }
            
            switch inputBuffer {
            case .buffer(let buffer):
                encoder.setFragmentBuffer(buffer, offset: 0, index: i)
            default:
                NSLog("passed texture as buffer")
                continue
            }
            
        }
        
        //set fragment textures
        for i in 0..<pipeline.getFragmentFunction().getTextures() {
            
            guard let inputBuffer = inputs[.Texture] else {
                NSLog("Did not submit input of type Texture")
                return
            }
            
            switch inputBuffer {
            case .texture(let textures):
                
                for (i, texture) in textures.enumerated() {
                    encoder.setFragmentTexture(texture, index: i)
                }
                
            default:
                NSLog("passed texture as buffer")
                continue
            }
            
        }
        
    }
    
    static func encodeComputeCommand(inputs: [ShaderTypes: MTLBuffer], pipeline: ComputeState, encoder: MTLComputeCommandEncoder) {
        
        guard let pipelineState = pipeline.getMTLState() else {
            NSLog("Failed to get pipeline State")
            return
        }
        encoder.setComputePipelineState(pipelineState)
        
        //set input buffers
        for (i, vInput) in pipeline.getComputeFunction().getInputs().enumerated() {
            
            guard let inputBuffer = inputs[vInput] else {
                NSLog("Did not submit input of type \(vInput)")
                return
            }
            
            encoder.setBuffer(inputBuffer, offset: 0, index: i)
            
        }
        
    }
    
}
