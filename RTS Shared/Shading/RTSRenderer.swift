//
//  RTSRenderer.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 05.03.24.
//

import Foundation
import Metal
import MetalKit
import simd

class RTSRenderer: NSObject, MTKViewDelegate, RTSGameDelegate {
    
    static let renderedFrames = 3
    let inFlightSemaphore: DispatchSemaphore = DispatchSemaphore(value: renderedFrames)
    
    var objects:[Object] = []
    
    var camera: Camera
    
    var commDelegate: RTSCommunicationDelegate
    
    var game: RTSGame?
    
    var vertecies: [Vertex] = []
    
    var updated = true
    var gameTime = 0.0
    
    init?(metalKitView: MTKView) {
        
        commDelegate = RTSCommunicationDelegate()
        
        let map = RTSMap_square(width: 100, height: 100)
        let players = [Player(name: "Max")]
        
        game = RTSGame(players: players, map: map, selfPlayer: players[0], delegate: nil, commDelegate: commDelegate)
        
        self.camera = Camera(pos: Vector3(x: 0, y: 0, z: -1), nearClip: 0.1, farClip: 100)
        let dir = Vector3(phi: -Float.pi / 2, theta: Float.pi / 2 - 0.1)
        self.camera.direction = dir
        
        if let sky = Object.MakeCube(color: Vector3(x: 38.0 / 255.0, y: 194.0 / 255.0, z: 220.0 / 255.0), label: "Skybox") {
            //self.objects.append(sky)
        }
        
        if let mapObj = Object(verticies: RTSRenderer.sampleMap(from: map, with: 100), pipelineState: .basic, label: "Map") {
            self.objects.append(mapObj)
        }
        
        do {
            let p = try Vertex.readFile("Drone")
            if let obj = Object(verticies: p, pipelineState: .basic, label: "Drone") {
                self.objects.append(obj)
            }
        }catch{
            print("error reading file")
        }
        
        super.init()
        
        self.game?.delegate = self
        
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
        let aspectRatio = Float(size.width / size.height)
        self.camera.aspectRatio = aspectRatio
        
    }
    
    private func updateGameState() {
        /// Update any game state before rendering
        
        //let rotationAxis = Vector3(x: 0, y: 0, z: 1)
        //let m = Matrix.matrix4x4_rotation(radians: 0.01, axis: rotationAxis)
        //objects[0].rotateBy(m)
        
        /*gameTime += 0.1
        let viewAngle = 0.01*gameTime
        let pos = Vector3(x: Float(cos(viewAngle)), y: Float(sin(viewAngle)), z: -1)
        self.camera.position = pos*/
    }
    
    func draw(in view: MTKView) {
        
        _ = inFlightSemaphore.wait(timeout: DispatchTime.distantFuture)

        if let commandBuffer = Engine.CommandQueue.makeCommandBuffer() {
            
            let semaphore = inFlightSemaphore
            commandBuffer.addCompletedHandler { (_ commandBuffer)-> Swift.Void in
                semaphore.signal()
            }
            
            self.updateGameState()
            
            /// Delay getting the currentRenderPassDescriptor until we absolutely need it to avoid
            ///   holding onto the drawable and blocking the display pipeline any longer than necessary
            let renderPassDescriptor = view.currentRenderPassDescriptor
                
            if let passDesc = renderPassDescriptor {
                
                if let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDesc) {
                    
                    if let cameraBuffer = self.camera.transformationBuffer {
                        
                        encoder.setVertexBuffer(cameraBuffer, offset: 0, index: EngineSettings.CameraBufferIndex)
                        
                        for object in objects {
                            object.draw(to: encoder)
                        }
                        
                        encoder.endEncoding()
                        
                        if let drawable = view.currentDrawable {
                            commandBuffer.present(drawable)
                        }
                        
                    }
                    
                }
                
            }
            
            commandBuffer.commit()
            
        }
        
    }
    
    func gameDidStart(_ game: RTSGame) {
        
    }
    
    func playerDidMove(_ game: RTSGame, player: Player, to position: Vector2) {
        
        self.camera.position = Vector3(x: position.x, y: position.y, z: 0)
        //let newPos = Vector3(x: position.x, y: position.y, z: 1)
        //self.objects[1].moveTo(newPos)
        
    }
    
    func gameDidEnd(_ game: RTSGame) {
        
    }
    
    func setGame(_ game: RTSGame) {
        self.game = game
    }
    
    func userDidClick(on pos: Vector2) {
        self.game?.move(pos)
    }
    
}

enum RendererError: Error {
    case badVertexDescriptor
    case bufferCreationFailed
    case invalidArgument
}


