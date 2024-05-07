//
//  ComputeStateLibrary.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 07.04.24.
//

import Foundation
import Metal

enum ComputeState: String, CaseIterable {
    
    case perlinMap = "perlinMap"
    
    func getComputeFunction() -> MetalComputeFunction {
        switch self {
        case .perlinMap:
            return .computePerlinHeight
        }
    }
    
    func getMTLState() -> MTLComputePipelineState? {
        guard let function = ComputeStateLibrary.states[self] else {
            NSLog("Couldn't find State '\(self.rawValue)'")
            return nil
        }
        
        return function
    }
    
}

struct ComputeStateLibrary {
    
    @available(*, unavailable) private init() {}
    
    fileprivate static var states: [ComputeState: MTLComputePipelineState] = [:]
    
    public static func Boot() {
        
        for s in ComputeState.allCases {
            
            do {
                
                guard let f = s.getComputeFunction().getMTLFunction() else { continue }
                let pipelineState = try Engine.Device.makeComputePipelineState(function: f)
                
                ComputeStateLibrary.states.updateValue(pipelineState, forKey: s)
                
            }catch{
                NSLog("failed to create Pipeline State \(s.rawValue)")
            }
            
        }
        
    }
    
}
