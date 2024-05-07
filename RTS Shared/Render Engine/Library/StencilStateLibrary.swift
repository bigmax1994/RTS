//
//  StencilStateLibrary.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 21.03.24.
//

import Foundation
import Metal

enum StencilState: String, CaseIterable {
    
    static func getDefault() -> StencilState {
        return .lessEqual
    }
    
    case always
    case never
    case equal
    case notEqual
    case greater
    case greaterEqual
    case less
    case lessEqual
    
    func getMTLFunction() -> MTLCompareFunction {
        switch self {
        case .always:
                .always
        case .never:
                .never
        case .equal:
                .equal
        case .notEqual:
                .notEqual
        case .greater:
                .greater
        case .greaterEqual:
                .greaterEqual
        case .less:
                .less
        case .lessEqual:
                .lessEqual
        }
    }
    
    func getMTLState() -> MTLDepthStencilState? {
        guard let state = StencilStateLibrary.states[self] else {
            NSLog("Couldn't find State '\(self.rawValue)'")
            return nil
        }
        return state
    }
    
}

struct StencilStateLibrary {
    
    @available(*, unavailable) private init() {}
    
    fileprivate static var states: [StencilState: MTLDepthStencilState] = [:]
    
    public static func Boot() {
        
        for s in StencilState.allCases {
            
            let descriptor = MTLDepthStencilDescriptor()
            
            descriptor.depthCompareFunction = s.getMTLFunction()
            descriptor.isDepthWriteEnabled = true
            
            guard let stencilState = Engine.Device.makeDepthStencilState(descriptor: descriptor) else { continue }
            
            StencilStateLibrary.states.updateValue(stencilState, forKey: s)
            
        }
        
    }
    
}
