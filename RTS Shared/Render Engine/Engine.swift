//
//  Engine.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 20.03.24.
//

import Foundation
import Metal
import MetalKit

struct Engine {
    
    @available(*, unavailable) private init() {}
    
    static var Device: MTLDevice!
    static var CommandQueue: MTLCommandQueue!
    
    public static func Boot(to view: MTKView) {
        
        //Boot Metal
        guard let device = MTLCreateSystemDefaultDevice() else {
            NSLog("Metal unavailable")
            return
        }
        Engine.Device = device
        
        view.device = Engine.Device
        view.depthStencilPixelFormat = Engine.depthFormat
        
        //Create Command Queue
        guard let queue = Engine.Device.makeCommandQueue() else {
            NSLog("Command Queue unavailable")
            return
        }
        Engine.CommandQueue = queue
        
        //Boot Libraries
        FunctionLibrary.Boot()
        PipelineStateLibrary.Boot()
        StencilStateLibrary.Boot()
        
    }
    
}
