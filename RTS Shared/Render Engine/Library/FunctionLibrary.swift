//
//  FunctionLibrary.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 20.03.24.
//

import Foundation
import Metal

enum MetalVertexFunction: String, CaseIterable {
    case vertex = "vertexShader"
    
    func getMTLFunction() -> MTLFunction? {
        
        guard let function = FunctionLibrary.vertexFunctions[self] else {
            NSLog("Couldn't find Function '\(self.rawValue)'")
            return nil
        }
        
        return function
        
    }
    
}

enum MetalFragmentFunction: String, CaseIterable {
    case fragment = "fragmentShader"
    
    func getMTLFunction() -> MTLFunction? {
        
        guard let function = FunctionLibrary.fragmentFunctions[self] else {
            NSLog("Couldn't find Function '\(self.rawValue)'")
            return nil
        }
        
        return function
        
    }
    
}

class FunctionLibrary {
    
    public static var library: MTLLibrary!
    
    public static var vertexFunctions: [MetalVertexFunction: MTLFunction] = [:]
    public static var fragmentFunctions: [MetalFragmentFunction: MTLFunction] = [:]
    
    public static func Boot() {
        
        FunctionLibrary.library = Engine.Device.makeDefaultLibrary()
        
        for f in MetalVertexFunction.allCases {
            
            if let function = FunctionLibrary.library.makeFunction(name: f.rawValue) {
                FunctionLibrary.vertexFunctions.updateValue(function, forKey: f)
            }else{
                NSLog("failed to create '\(f.rawValue)' Function")
            }
            
        }
        
        for f in MetalFragmentFunction.allCases {
            
            if let function = FunctionLibrary.library.makeFunction(name: f.rawValue) {
                FunctionLibrary.fragmentFunctions.updateValue(function, forKey: f)
            }else{
                NSLog("failed to create '\(f.rawValue)' Function")
            }
            
        }
        
    }
    
}
