//
//  FunctionLibrary.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 20.03.24.
//

import Foundation
import Metal

enum MetalVertexFunction: String, CaseIterable {
    
    static func getDefault() -> MetalVertexFunction {
        return .vertexColor
    }
    
    case vertexColor = "colorVertexShader"
    case planeVertex = "planeVertexShader"
    case vertexTexture = "textureVertexShader"
    
    func getMTLFunction() -> MTLFunction? {
        
        guard let function = FunctionLibrary.vertexFunctions[self] else {
            NSLog("Couldn't find Function '\(self.rawValue)'")
            return nil
        }
        
        return function
        
    }
    
    func getInputs() -> [ShaderTypes] {
        
        switch self {
        case .vertexColor:
            return [.CameraTransformation, .Transformation, .Vertex]
        case .planeVertex:
            return [.Vertex]
        case .vertexTexture:
            return [.CameraTransformation, .Transformation, .TextureVertex]
        }
        
    }
    
}

enum MetalFragmentFunction: String, CaseIterable {
    
    static func getDefault() -> MetalFragmentFunction {
        return .fragmentColor
    }
    
    case fragmentColor = "colorFragmentShader"
    case fragmentTexture = "textureFragmentShader"
    
    func getMTLFunction() -> MTLFunction? {
        
        guard let function = FunctionLibrary.fragmentFunctions[self] else {
            NSLog("Couldn't find Function '\(self.rawValue)'")
            return nil
        }
        
        return function
        
    }
    
    func getInputs() -> [ShaderTypes] {
        
        switch self {
        case .fragmentColor:
            return [.CameraTransformation, .Light]
        case .fragmentTexture:
            return [.CameraTransformation, .Light]
        }
        
    }
    
    func getTextures() -> Int {
        
        switch self {
        case .fragmentColor:
            return 0
        case .fragmentTexture:
            return 1
        }
        
    }
    
}

enum MetalComputeFunction: String, CaseIterable {
    
    case computePerlinHeight = "computePerlinHeight"
    
    func getMTLFunction() -> MTLFunction? {
        
        guard let function = FunctionLibrary.computeFunctions[self] else {
            NSLog("Couldn't find Function '\(self.rawValue)'")
            return nil
        }
        
        return function
        
    }
    
    func getInputs() -> [ShaderTypes] {
        
        switch self {
        case .computePerlinHeight:
            return []
        }
        
    }
    
}

struct FunctionLibrary {
    
    @available(*, unavailable) private init() {}
    
    public static var library: MTLLibrary!
    
    fileprivate static var vertexFunctions: [MetalVertexFunction: MTLFunction] = [:]
    fileprivate static var fragmentFunctions: [MetalFragmentFunction: MTLFunction] = [:]
    fileprivate static var computeFunctions: [MetalComputeFunction: MTLFunction] = [:]
    
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
        
        for f in MetalComputeFunction.allCases {
            
            if let function = FunctionLibrary.library.makeFunction(name: f.rawValue) {
                FunctionLibrary.computeFunctions.updateValue(function, forKey: f)
            }else{
                NSLog("failed to create '\(f.rawValue)' Function")
            }
            
        }
        
    }
    
}
