//
//  PipelineStateLibrary.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 20.03.24.
//

import Foundation
import Metal

enum PipelineState: String, CaseIterable {
    
    static func getDefault() -> PipelineState {
        return .basic
    }
    
    case basic = "basic"
    case plane = "plane"
    case texture = "texture"
    
    func getVertexFunction() -> MetalVertexFunction {
        switch self {
        case .basic:
            return .vertexColor
        case.plane:
            return .planeVertex
        case .texture:
            return .vertexTexture
        }
    }
    
    func getFragmentFunction() -> MetalFragmentFunction {
        switch self {
        case .basic:
            return .fragmentColor
        case.plane:
            return .fragmentColor
        case .texture:
            return .fragmentTexture
        }
    }
    
    func getMTLState() -> MTLRenderPipelineState? {
        guard let function = PipelineStateLibrary.states[self] else {
            NSLog("Couldn't find State '\(self.rawValue)'")
            return nil
        }
        
        return function
    }
    
}

struct PipelineStateLibrary {
    
    @available(*, unavailable) private init() {}
    
    fileprivate static var states: [PipelineState: MTLRenderPipelineState] = [:]
    
    public static func Boot() {
        
        for s in PipelineState.allCases {
            
            let descriptor = MTLRenderPipelineDescriptor()
            
            descriptor.vertexFunction = s.getVertexFunction().getMTLFunction()
            descriptor.fragmentFunction = s.getFragmentFunction().getMTLFunction()
            
            descriptor.colorAttachments[0].pixelFormat = Engine.pixelFormat
            descriptor.colorAttachments[0].isBlendingEnabled = true
            descriptor.colorAttachments[0].rgbBlendOperation = .add
            descriptor.colorAttachments[0].alphaBlendOperation = .add
            descriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
            descriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
            descriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
            descriptor.depthAttachmentPixelFormat = Engine.depthFormat
            descriptor.stencilAttachmentPixelFormat = Engine.stencilFormat
            
            do {
                let pipelineState = try Engine.Device.makeRenderPipelineState(descriptor: descriptor)
                
                PipelineStateLibrary.states.updateValue(pipelineState, forKey: s)
                
            }catch{
                NSLog("failed to create Pipeline State \(s.rawValue)")
            }
            
        }
        
    }
    
}
