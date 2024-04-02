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
    
    var world: World
    
    var commDelegate: RTSCommunicationDelegate
    
    var game: RTSGame?
    
    var updated = true
    var gameTime = 0.0
    var mousePosition:Vector2 = Vector2()
    var mouseIsDown:Bool = false
    
    let cameraHeight:Float = 0.3
    let droneHeight:Float = 0.2
    
    init?(metalKitView: MTKView) {
        
        self.world = World(sunPos: Vector3(x: 0.5, y: 0, z: 1))
        
        commDelegate = RTSCommunicationDelegate()
        let cameraTiltMatrix = Matrix.matrix3x3_rotation(radians: 0.2, axis: Vector3(x: 1, y: 0, z: 0))
        let cDir = cameraTiltMatrix * Vector3(x: 0, y: 0, z: -1)
        let cUp = cameraTiltMatrix * Vector3(x: 0, y: 1, z: 0)
        
        self.world.camera = Camera(pos: Vector3(x: 0, y: 0, z: cameraHeight),
                             dir: cDir,
                             up: cUp,
                             nearClip: 0.001, farClip: 100)
        
        let map = RTSMap_square(width: 200, height: 200)
        let players = [Player(name: "Max"), Player(name: "Magnus"), Player(name:"Thomas"), Player(name:"Tabea")]
            
        game = RTSGame(players: players, map: map, selfPlayer: players[0], delegate: nil, commDelegate: commDelegate)
        
        if let sky = Object.MakeCube(color: simd_float3(38.0 / 255.0, 194.0 / 255.0, 220.0 / 255.0), label: "Skybox") {
            sky.scaleTo(10)
            //self.objects.append(sky)
        }
        
        if let mapObj = Object(verticies: RTSRenderer.sampleMap(from: map, with: 450), pipelineState: .basic, label: "Map") {
            
            let scaleVec = Vector3(x: 1, y: 1, z: 0.2)
            mapObj.scaleTo(scaleVec)
            
            self.world.objects.append(mapObj)
        }
        
        do {
            let p = try Vertex.readFile("Drone")
            if let obj = Object(verticies: p, pipelineState: .basic, label: "Drone") {
                obj.moveTo(Vector3(x: 0, y: 0, z: droneHeight))
                obj.scaleTo(0.025)
                self.world.objects.append(obj)
                players[0].playerChar = obj
            }
        }catch{
            print("error reading file")
        }
        super.init()
        game?.delegate = self
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
        let aspectRatio = Float(size.width / size.height)
        self.camera.aspectRatio = aspectRatio
        
    }
    
    private func updateGameState() {
        /// Update any game state before rendering
        
        game?.onTick()
    }
    
    func draw(in view: MTKView) {
        
        _ = inFlightSemaphore.wait(timeout: DispatchTime.distantFuture)

        if let commandBuffer = Engine.CommandQueue.makeCommandBuffer() {
            
            let semaphore = inFlightSemaphore
            commandBuffer.addCompletedHandler { (_ commandBuffer)-> Swift.Void in
                semaphore.signal()
            }
            
            self.updateGameState()
            
            view.clearDepth = 1
            
            /// Delay getting the currentRenderPassDescriptor until we absolutely need it to avoid
            ///   holding onto the drawable and blocking the display pipeline any longer than necessary
            let renderPassDescriptor = view.currentRenderPassDescriptor
                
            if let passDesc = renderPassDescriptor {
                
                if let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDesc) {
                    
                    self.world.draw(to: encoder)
                    
                }
                
            }
            
            commandBuffer.commit()
            
        }
        
    }
    
    func gameDidStart(_ game: RTSGame) {
        
    }
    
    func renderPlayerMovement(_ game: RTSGame, player: Player, to position: Vector2, from oldPosition: Vector2) {
        
        let playerPos = Vector3(x: position.x, y: position.y, z: droneHeight)
        player.playerChar?.moveTo(playerPos)
        let movement = (position - oldPosition).normalized()
        
        let v1 = Vector3(x: 0, y: -1, z: 0)
        let v2 = Vector3(x: movement.x, y: movement.y, z: 0)
        
        let m = Matrix.solveForRotation3x3(from: v1, to: v2)
        player.playerChar?.rotateTo(m)
    }
    
    func setCameraPosition(_ game:RTSGame, to:Vector2){
        let camPos = Vector3(x: to.x, y: to.y, z: cameraHeight)
        self.camera.position = camPos
    }
    
    func gameDidEnd(_ game: RTSGame) {
        
    }
    
    func setGame(_ game: RTSGame) {
        self.game = game
    }
    
    func userDidClick(on pos: Vector2) {
        //adjust user click based on camera position
        let v3 = Vector3(x: pos.x, y: pos.y, z: 0)
        let transformedV3 = self.camera.transformationMatrix * v3
        let transformedV2 = Vector2(x: transformedV3.x, y: transformedV3.y)
        
        //send new position to game
        self.mouseIsDown = true
        self.game?.move(transformedV2)
    }
    func mouseDidMove(to pos: Vector2) {
        mousePosition = pos
        
    }
    func mouseReleased() {
        self.mouseIsDown = false
    }
    
}

enum RendererError: Error {
    case badVertexDescriptor
    case bufferCreationFailed
    case invalidArgument
}


