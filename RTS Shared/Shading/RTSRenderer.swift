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

let alignedUniformsSize = (MemoryLayout<Uniforms>.size + 0xFF) & -0x100

class RTSRenderer: NSObject, MTKViewDelegate, RTSGameDelegate {
    
    static let renderedFrames = 3
    let inFlightSemaphore: DispatchSemaphore = DispatchSemaphore(value: renderedFrames)
    
    var objects:[Object] = []
    
    var device: MTLDevice

    var camera: Camera
    var cameraBuffer: MTLBuffer
    
    var commandQueue: MTLCommandQueue
    var pipelineState: MTLRenderPipelineState
    
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
        
        let cameraPos = Vector3(x: 0, y: 0, z: map.heightMap.evaluate(v: Vector2()))
        self.camera = Camera(pos: cameraPos, dir: Vector3(x: 1, y: 0, z: 0), up: Vector3(x: 0, y: 0, z: -1))
        
        self.device = metalKitView.device!
        
        self.commandQueue = device.makeCommandQueue()!
        
        let cTrafo = self.camera.getTrafo()
        guard let cBuffer = device.makeBuffer(bytes: [cTrafo], length: MemoryLayout.size(ofValue: cTrafo)) else { return nil }
        self.cameraBuffer = cBuffer
        
        let desc = MTLRenderPipelineDescriptor()
        
        let library = device.makeDefaultLibrary()
        desc.vertexFunction = library?.makeFunction(name: "vertexShader")
        desc.fragmentFunction = library?.makeFunction(name: "fragmentShader")
        
        desc.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
        desc.depthAttachmentPixelFormat = metalKitView.depthStencilPixelFormat
        desc.stencilAttachmentPixelFormat = metalKitView.depthStencilPixelFormat
        
        do {
            self.pipelineState = try device.makeRenderPipelineState(descriptor: desc)
        }catch{
            fatalError("failed to compile pipeline")
        }
        
        if let mapObj = Object(verticies: RTSRenderer.sampleMap(from: map, with: 1000), device: device, label: "Map") {
            let cameraRotation = Matrix.matrix4x4_rotation(radians: 1, axis: Vector3(x: 1, y: 0, z: 0))
            //mapObj.rotateBy(cameraRotation)
            self.objects.append(mapObj)
        }
        
        if let sky = Skybox(color: Vector3(x: 38.0 / 255.0, y: 194.0 / 255.0, z: 220.0 / 255.0), device: device) {
            //self.objects.append(sky)
        }
        
        do {
            //let p = try Vertex.readFile("Drone")
            //if let obj = Object(verticies: p, device: device, label: "drone") {
                //self.objects.append(obj)
            //}
        }catch{
            print("error reading file")
        }
        
        super.init()
        
        self.game?.delegate = self
        
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    private func updateGameState() {
        /// Update any game state before rendering
        
        let rotationAxis = Vector3(x: 0, y: 0.5, z: 1)
        //let m = Matrix.matrix4x4_rotation(radians: 0.01, axis: rotationAxis)
        //objects[0].rotateBy(m)
        
        gameTime += 0.1
        let viewAngle = 0.01*gameTime
        let lookAt = Vector3(x:Float(sin(viewAngle)), y:0.0, z:Float(cos(viewAngle)))
        self.camera.setDir(lookAt)
        
        let cTrafo = self.camera.getTrafo()
        self.cameraBuffer = device.makeBuffer(bytes: [cTrafo], length: MemoryLayout.size(ofValue: cTrafo))!
    }
    
    func draw(in view: MTKView) {
        
        _ = inFlightSemaphore.wait(timeout: DispatchTime.distantFuture)

        if let commandBuffer = commandQueue.makeCommandBuffer() {
            let semaphore = inFlightSemaphore
            commandBuffer.addCompletedHandler { (_ commandBuffer)-> Swift.Void in
                semaphore.signal()
            }
            
            self.updateGameState()
            
            /// Delay getting the currentRenderPassDescriptor until we absolutely need it to avoid
            ///   holding onto the drawable and blocking the display pipeline any longer than necessary
            let renderPassDescriptor = view.currentRenderPassDescriptor
            
            for object in objects {
                object.draw(view, cmdBuffer: commandBuffer, pipelineState: self.pipelineState, device: device, cameraBuffer: self.cameraBuffer)
            }
                    
            if let drawable = view.currentDrawable {
                commandBuffer.present(drawable)
            }
            
            commandBuffer.commit()
        }
        
    }
    
    func addBuffer(_ buffer: MTLBuffer, vertexCount: Int, in view: MTKView, descriptor: MTLRenderPassDescriptor, pipelineState: MTLRenderPipelineState, commandBuffer: MTLCommandBuffer, clearScreen: Bool = false) {
        
        descriptor.colorAttachments[0].loadAction = MTLLoadAction.load
        descriptor.colorAttachments[0].storeAction = MTLStoreAction.store
        
        descriptor.depthAttachment.loadAction = MTLLoadAction.clear
        descriptor.depthAttachment.storeAction = MTLStoreAction.store
        
        /// Final pass rendering code here
        if let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) {
            renderEncoder.label = "Primary Render Encoder"
            
            //set vertecies and state
            renderEncoder.setRenderPipelineState(pipelineState)
            renderEncoder.setVertexBuffer(buffer, offset: 0, index: 0)
            renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount)
            /// Render scene using render encoder
            
            renderEncoder.endEncoding()
            
            if let drawable = view.currentDrawable {
                commandBuffer.present(drawable)
            }
        }
        
    }
    
    func gameDidStart(_ game: RTSGame) {
        
    }
    
    func playerDidMove(_ game: RTSGame, player: Player, to position: Vector2) {
        
        /*let _ = self.vertecies.removeLast(6)
        
        let fac:Float = 0.9
        
        let tileSize:(width: Float, height: Float) = (width: fac * 2/Float(game.map.width), height: fac * 2/Float(game.map.height))
        
        let playerPos:Vector2 = player.getPosition()
        let playerX = playerPos.x - tileSize.width / 2
        let playerEndX = playerPos.x + tileSize.height / 2
        let playerY = playerPos.y - tileSize.width / 2
        let playerEndY = playerPos.y + tileSize.height / 2
        
        let playerQuad = Quad(fromX: playerX, fromY: playerY, toX: playerEndX, toY: playerEndY, z: 0.1, color: [1,0,0])
        
        self.vertecies.append(contentsOf: playerQuad.verticies)
        
        let dataSize = self.vertecies.count * MemoryLayout.size(ofValue: self.vertecies[0])*/
        //self.vertexBuffer = device.makeBuffer(bytes: vertecies, length: dataSize, options: [])!
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


