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

        // Select the device to render with.  We choose the default device
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            print("Metal is not supported on this device")
            return
        }

        mtkView.device = defaultDevice

        guard let newRenderer = RTSRenderer(metalKitView: mtkView) else {
            print("Renderer cannot be initialized")
            return
        }

        renderer = newRenderer

        renderer.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)

        mtkView.delegate = renderer
    }
    
    override func mouseDown(with event: NSEvent) {
        let x = Float(event.locationInWindow.x - (event.window?.frame.width ?? 0) / 2)
        let y = Float(event.locationInWindow.y - (event.window?.frame.height ?? 0) / 2)
        
        let pos = Vector2(x: x, y: y)
        self.renderer.userDidClick(on: pos)
    }
    
}
