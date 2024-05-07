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
    
    enum State {
        case startScreen
        case game
    }
    
    var _state: State = .startScreen
    var state: State {
        get {
            return _state
        }
        set {
            self._state = newValue
            self.updateRenderedWorld()
        }
    }
    var renderedWorld:World? = nil
    
    var commDelegate: RTSCommunicationDelegate
    
    var gameWorld: World
    var game: RTSGame?
    
    var updated = true
    var gameTime = 0.0
    var mousePosition:Vector2 = Vector2()
    var mouseIsDown:Bool = false
    
    let cameraHeight:Float = 0.3
    let droneHeight:Float = 0.2
    
    init?(metalKitView: MTKView) {
        
        self.gameWorld = World(sunPos: Vector3(x: 0.5, y: 0, z: 1))
        
        let cameraTiltMatrix = Matrix.matrix3x3_rotation(radians: 0.2, axis: Vector3(x: 1, y: 0, z: 0))
        let cDir = cameraTiltMatrix * Vector3(x: 0, y: 0, z: -1)
        let cUp = cameraTiltMatrix * Vector3(x: 0, y: 1, z: 0)
        
        self.gameWorld.camera = Camera(pos: Vector3(x: 0, y: 0, z: cameraHeight),
                             dir: cDir,
                             up: cUp,
                             nearClip: 0.001, farClip: 100)
        
        let map = RTSMap_square(width: 200, height: 200)
        let players = [Player(name: "Max"), Player(name: "Magnus"), Player(name:"Thomas"), Player(name:"Tabea")]
            
        game = RTSGame(players: players, map: map, selfPlayer: players[0], delegate: nil, commDelegate: nil)
        
        commDelegate = RTSCommunicationDelegate(to: metalKitView, startGame: self.game?.startGame)
        
        if let sky = Object.MakeCube(color: simd_float3(38.0 / 255.0, 194.0 / 255.0, 220.0 / 255.0), label: "Skybox") {
            sky.scaleTo(10)
            //self.objects.append(sky)
        }
        
        if let mapObj = Object(verticies: RTSRenderer.sampleMap(from: map, with: 250), pipelineState: .basic, label: "Map") {
            
            let scaleVec = Vector3(x: 1, y: 1, z: 0.2)
            mapObj.scaleTo(scaleVec)
            
            self.gameWorld.objects.append(mapObj)
        }
        
        do {
            let p = try Vertex.readFile("Drone")
            if let obj = Object(verticies: p, pipelineState: .basic, label: "Drone") {
                obj.moveTo(Vector3(x: 0, y: 0, z: droneHeight))
                obj.scaleTo(0.025)
                self.gameWorld.objects.append(obj)
                players[0].playerChar = obj
            }
        }catch{
            print("error reading file")
        }
        super.init()
        
        game?.delegate = self
        game?.commDelegate = self.commDelegate
        
        self.state = .startScreen
        
        let attrString = NSAttributedString(string: "Hello", attributes: [.foregroundColor: CGColor.white])
        guard let img = CIFilter(name: "CIAttributedTextImageGenerator", parameters: [
            "inputText": attrString
        ])?.outputImage else {
            return
        }
        
        /*try! Engine.CIContext.pngRepresentation(of: img, format: .RGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())?.write(to: URL(fileURLWithPath: "/Users/maxgasslitterstrobl/Downloads/test.png"))
        guard let draw = metalKitView.currentDrawable else { return }
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let buff = Engine.CommandQueue.makeCommandBuffer() else {return}
        Engine.CIContext.render(img, to: draw.texture, commandBuffer: buff, bounds: img.extent, colorSpace: colorSpace)
        buff.present(draw)
        buff.commit()*/
    }
    
    func updateRenderedWorld() {
        
        switch self.state {
        case .startScreen:
            self.renderedWorld = self.commDelegate.selectScreen
        case .game:
            self.renderedWorld = self.gameWorld
        }
        
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
        let aspectRatio = Float(size.width / size.height)
        self.gameWorld.camera.aspectRatio = aspectRatio
        
    }
    
    private func updateGameState() {
        /// Update any game state before rendering
        
        
    }
    
    func draw(in view: MTKView) {
        
        renderedWorld?.render(to: view)
        
    }
    
    func gameDidStart(_ game: RTSGame) {
        
        self.state = .game
        
    }
    
    func game(_ game: RTSGame, player: Player, didMoveTo position: Vector2, from oldPosition: Vector2) {
        
        let new3 = Vector3(x: position.x, y: position.y, z: droneHeight)
        let old3 = Vector3(x: oldPosition.x, y: oldPosition.y, z: droneHeight)
        guard let playerChar = player.playerChar else { return }
        self.gameWorld.animationSet.addAnimation(to: new3, from: old3, callback: playerChar.moveTo(_:), time: 0.1)
        let movement = (position - oldPosition).normalized()
        
        let v1 = Vector3(x: 0, y: -1, z: 0)
        let v2 = Vector3(x: movement.x, y: movement.y, z: 0)
        
        let m = Matrix.solveForRotation3x3(from: v1, to: v2)
        player.playerChar?.rotateTo(m)
        
        if player == game.selfPlayer {
            let camPos = Vector3(x: position.x, y: position.y, z: cameraHeight)
            
            self.gameWorld.animationSet.addAnimation(to: camPos, from: self.gameWorld.camera.position, callback: self.gameWorld.camera.setPosition(_:), time: 0.1)
        }
        
    }
    
    func gameDidEnd(_ game: RTSGame) {
        
    }
    
    func setGame(_ game: RTSGame) {
        self.game = game
    }
    
    func userDidClick(on pos: Vector2) {
        
        self.commDelegate.selectScreen.ui?.clicked(at: pos)
        
        //adjust user click based on camera position
        let v3 = Vector3(x: pos.x, y: pos.y, z: 0)
        let transformedV3 = self.gameWorld.camera.transformationMatrix * v3
        let transformedV2 = Vector2(x: transformedV3.x, y: transformedV3.y)
        
        //send new position to game
        self.mouseIsDown = true
        self.game?.moveSelfTowards(transformedV2)
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


