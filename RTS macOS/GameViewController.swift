//
//  GameViewController.swift
//  RTS macOS
//
//  Created by Max Gasslitter Strobl on 05.03.24.
//

import Cocoa
import MetalKit

// Our macOS specific view controller
class GameViewController: NSViewController {

    var renderer: RTSRenderer!
    var mtkView: MTKView!

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let mtkView = self.view as? MTKView else {
            print("View attached to GameViewController is not an MTKView")
            return
        }

        Engine.Boot(to: mtkView)

        guard let newRenderer = RTSRenderer(metalKitView: mtkView) else {
            print("Renderer cannot be initialized")
            return
        }

        renderer = newRenderer

        renderer.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)

        mtkView.delegate = renderer
    }
    
    override func mouseDown(with event: NSEvent) {
        if let window = event.window {
            let x = 2 * Float(event.locationInWindow.x / window.frame.width) - 1
            let y = 2 * Float(event.locationInWindow.y / window.frame.height) - 1
            
            let pos = Vector2(x: x, y: y)
            self.renderer.userDidClick(on: pos)
                          
        }
                              
    }
    
}
