//
//  RTSGame.swift
//  RTS iOS
//
//  Created by Max Gasslitter Strobl on 05.03.24.
//

import Foundation

class RTSGame {
    
    var delegate: RTSGameDelegate?
    var commDelegate: RTSCommunicationDelegate?
    var players: [UUID : Player]
    var selfPlayer: Player?
    var map: RTSMap
    var animationQueue:AnimationQueue
    var lastUpdate:TimeInterval
    
    //function to initialize the game
    init(players: [Player], map: RTSMap, selfPlayer: Player? = nil, delegate: RTSGameDelegate? = nil, commDelegate: RTSCommunicationDelegate? = nil) {
        self.delegate = delegate
        self.commDelegate = commDelegate
        self.players = players.reduce(into: [UUID : Player](), { partialResult, player in
            partialResult[player.uuid] = player
        })
        self.selfPlayer = selfPlayer
        self.map = map
        self.lastUpdate = Date().timeIntervalSince1970
        self.animationQueue = AnimationQueue(game:nil)
        self.animationQueue = AnimationQueue(game:self)
        
        
        commDelegate?.setGame(self)
        delegate?.setGame(self)
    }
    
    //function to start the game
    func startGame() {
        //reset the map
        map.reset()
        
        //determine player starting positions
        for player in players.values {
            player.moveTo(distributePlayer(target: Vector2()))
        }
        
    }
    func onTick(){
        let now = Date().timeIntervalSince1970
        self.animationQueue.update(timeSinceLastUpate: Float(now - lastUpdate))
        self.lastUpdate = now
        
        if animationQueue.queue.isEmpty{
            if let del = delegate{
                let renderer = del as! RTSRenderer
                if renderer.mouseIsDown{
                    let v3 = Vector3(x: renderer.mousePosition.x, y: renderer.mousePosition.y, z: 0)
                    let transformedV3 = renderer.world.camera.transformationMatrix * v3
                    let transformedV2 = Vector2(x: transformedV3.x, y: transformedV3.y)
                    move(transformedV2)
                }
            }
        }
    }
    
    //function to move player
    func move(_ direction: Vector2) {
        
        //check if current device is controlling a player
        if let p = self.selfPlayer {
            movePlayerTowards(p: p, direction: direction)            //
        }
        
    }
    /// chooses random starting position for a player
    func distributePlayer(target: Vector2, deviation: Float = 0.1) -> Vector2 {
        // angle a in [0, 2pi]
        let a = Float.random(in: 0..<2 * Float.pi)
        // distance d in [0, 1]
        let d = Float.random(in: 0..<1)
        // (x,y) in [-1, 1]^2
        var v = Vector2(x: cos(a) * d, y: sin(a) * d)
        while !map.checkIfPositionIsAllowed(target + deviation * v) {
            v = 0.5*v
        }
        return target + deviation * v
    }
    ///spread out the players on the map
    func distributePlayersStep() {
        for player in players.values{
            var disgustVect = Vector2()
            for otherPlayer in players.values{
                let diff:Vector2 = otherPlayer.getCurrentPosition() - player.getCurrentPosition()
                disgustVect = disgustVect + 1/(diff.length()*diff.length()) * diff
            }
            movePlayerTowards(p: player, direction: -1*disgustVect)
        }
        
    }
    func movePlayerTowards(p:Player, direction:Vector2){
        if direction.length() < 0.001 {return}
        let vec = RTSGame.movementSpeed * direction.normalized()
        self.animationQueue.addMovement(to:p.getFuturePosition()+vec, p: p)
        p.moveBy(vec)
        self.commDelegate?.playerDidMove(p, to: p.getFuturePosition())
    }
    func updateMovement(from:Vector2, to:Vector2, p:Player){
        self.delegate?.renderPlayerMovement(self, player: p, to: to, from: from)
        if p===self.selfPlayer{
            self.delegate?.setCameraPosition(self, to: to)
        }
    }
    
}
