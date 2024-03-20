//
//  GameViewController.swift
//  RTS iOS
//
//  Created by Max Gasslitter Strobl on 05.03.24.
//

import UIKit
import MetalKit

// Our iOS specific view controller
class GameViewController: UIViewController {

    var renderer: RTSRenderer!
    var mtkView: MTKView!

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let mtkView = self.view as? MTKView else {
            print("View of Gameview controller is not an MTKView")
            return
        }
        
        Engine.Boot()
        mtkView.device = Engine.Device
        mtkView.backgroundColor = UIColor.black

        guard let newRenderer = RTSRenderer(metalKitView: mtkView) else {
            print("Renderer cannot be initialized")
            return
        }

        renderer = newRenderer

        renderer.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)

        mtkView.delegate = renderer
    }
}
