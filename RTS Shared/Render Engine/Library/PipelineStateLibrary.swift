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
    
    func getVertexFunction() -> MetalVertexFunction {
        switch self {
        case .basic:
            return .vertex
        }
    }
    
    func getFragmentFunction() -> MetalFragmentFunction {
        switch self {
        case .basic:
            return .fragment
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

class PipelineStateLibrary {
    
    fileprivate static var states: [PipelineState: MTLRenderPipelineState] = [:]
    
    public static func Boot() {
        
        for s in PipelineState.allCases {
            
            let descriptor = MTLRenderPipelineDescriptor()
            
            descriptor.vertexFunction = s.getVertexFunction().getMTLFunction()
            descriptor.fragmentFunction = s.getFragmentFunction().getMTLFunction()
            
            descriptor.colorAttachments[0].pixelFormat = EngineSettings.pixelFormat
            descriptor.depthAttachmentPixelFormat = EngineSettings.depthFormat
            descriptor.stencilAttachmentPixelFormat = EngineSettings.stencilFormat
            
            do {
                let pipelineState = try Engine.Device.makeRenderPipelineState(descriptor: descriptor)
                
                PipelineStateLibrary.states.updateValue(pipelineState, forKey: s)
                
            }catch{
                NSLog("failed to create Pipeline State \(s.rawValue)")
            }
            
        }
        
    }
    
}
