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
    
    func gameDidStart(_ game: RTSGame) {
        
    }
    
    func playerDidMove(_ game: RTSGame, player: Player, to position: Vector2) {
        
        let _ = self.vertecies.removeLast(6)
        
        let fac:Float = 0.9
        
        let tileSize:(width: Float, height: Float) = (width: fac * 2/Float(game.map.width), height: fac * 2/Float(game.map.height))
        
        let playerPos:Vector2 = player.getPosition()
        let playerX = playerPos.x - tileSize.width / 2
        let playerEndX = playerPos.x + tileSize.height / 2
        let playerY = playerPos.y - tileSize.width / 2
        let playerEndY = playerPos.y + tileSize.height / 2
        
        let playerQuad = Quad(fromX: playerX, fromY: playerY, toX: playerEndX, toY: playerEndY, z: 0.1, color: [1,0,0])
        
        self.vertecies.append(contentsOf: playerQuad.verticies)
        
        let dataSize = self.vertecies.count * MemoryLayout.size(ofValue: self.vertecies[0])
        self.vertexBuffer = device.makeBuffer(bytes: vertecies, length: dataSize, options: [])!
        
        updated = true
    }
    
    func gameDidEnd(_ game: RTSGame) {
        
    }
    
    func setGame(_ game: RTSGame) {
        self.game = game
    }
    
    func userDidClick(on pos: Vector2) {
        self.game?.move(pos)
    }
    
    
    var device: MTLDevice
    var vertexBuffer: MTLBuffer!
    var commandQueue: MTLCommandQueue
    var pipelineState: MTLRenderPipelineState
    
    var commDelegate: RTSCommunicationDelegate
    
    var game: RTSGame?
    
    var vertecies: [Vertex] = []
    
    var updated = true
    
    init?(metalKitView: MTKView) {
        
        commDelegate = RTSCommunicationDelegate()
        
        let map = RTSMap_square(width: 100, height: 100)
        let players = [Player(name: "Max")]
        
        game = RTSGame(players: players, map: map, selfPlayer: players[0], delegate: nil, commDelegate: commDelegate)
        
        let tileSize:(width: Float, height: Float) = (width: 2/Float(map.width), height: 2/Float(map.height))
        
        for i in 0..<map.height {
            
            var v:[Vertex] = []
            
            let y = Float(i) * tileSize.height - 1
            let endY = Float(i + 1) * tileSize.height - 1
            
            for j in 0..<map.width {
                
                let x = Float(j) * tileSize.height - 1
                let endX = Float(j + 1) * tileSize.width - 1
                    
                var color:[Float]
                switch map.tiles[i * map.height + j] {
                case .grass:
                    color = [0, 1, 0]
                case .water:
                    color = [0, 0, 1]
                case .mountain:
                    color = [0.7631, 0.4432, 0.1306]
                case .post:
                    color = [0.5, 0.5, 0.5]
                case .activePost:
                    color = [0.4176, 0.4153, 0.7561]
                case .closedPost:
                    color = [0.6186, 0.4153, 0.7561]
                default:
                    color = [0,0,0]
                }
                
                let quad = Quad(fromX: x, fromY: y, toX: endX, toY: endY, color: color)
                
                v.append(contentsOf: quad.verticies)
                
            }
            
            self.vertecies.append(contentsOf: v)
            
        }
        
        let playerPos:Vector2 = game!.selfPlayer!.getPosition()
        let playerX = playerPos.x - tileSize.width / 2
        let playerEndX = playerPos.x + tileSize.height / 2
        let playerY = playerPos.y - tileSize.width / 2
        let playerEndY = playerPos.y + tileSize.height / 2
        
        let playerQuad = Quad(fromX: playerX, fromY: playerY, toX: playerEndX, toY: playerEndY, z: 0.1, color: [1,0,0])
        
        self.vertecies.append(contentsOf: playerQuad.verticies)
        self.vertecies[vertecies.count - 1].pos.z = -0.1
        
        self.device = metalKitView.device!
        
        self.commandQueue = device.makeCommandQueue()!
        
        let dataSize = self.vertecies.count * MemoryLayout.size(ofValue: self.vertecies[0])
        self.vertexBuffer = device.makeBuffer(bytes: vertecies, length: dataSize, options: [])!
        
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
        
        super.init()
        
        self.game?.delegate = self
        
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        
        _ = inFlightSemaphore.wait(timeout: DispatchTime.distantFuture)

        if let commandBuffer = commandQueue.makeCommandBuffer() {
            let semaphore = inFlightSemaphore
            commandBuffer.addCompletedHandler { (_ commandBuffer)-> Swift.Void in
                semaphore.signal()
            }
            
            /// Delay getting the currentRenderPassDescriptor until we absolutely need it to avoid
            ///   holding onto the drawable and blocking the display pipeline any longer than necessary
            let renderPassDescriptor = view.currentRenderPassDescriptor
            
            if let renderPassDescriptor = renderPassDescriptor {
                
                /// Final pass rendering code here
                if let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) {
                    renderEncoder.label = "Primary Render Encoder"
                    
                    //set vertecies and state
                    renderEncoder.setRenderPipelineState(pipelineState)
                    renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
                    renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertecies.count)
                    /// Render scene using render encoder
                    
                    renderEncoder.endEncoding()
                    
                    if let drawable = view.currentDrawable {
                        commandBuffer.present(drawable)
                    }
                }
            }
            
            commandBuffer.commit()
        }
        
    }
    
}
