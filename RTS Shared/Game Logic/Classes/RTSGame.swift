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
    
    //function to initialize the game
    init(players: [Player], map: RTSMap, selfPlayer: Player? = nil, delegate: RTSGameDelegate? = nil, commDelegate: RTSCommunicationDelegate? = nil) {
        self.delegate = delegate
        self.commDelegate = commDelegate
        self.players = players.reduce(into: [UUID : Player](), { partialResult, player in
            partialResult[player.uuid] = player
        })
        self.selfPlayer = selfPlayer
        self.map = map
        
        commDelegate?.setGame(self)
        delegate?.setGame(self)
    }
    
    //function to start the game
    func startGame() {
        //reset the map
        map.reset()
        
        //determine player starting positions
        for player in players.values {
            //player.moveTo(distributePlayer(target: Vector2()))
        }
        
        delegate?.gameDidStart(self)
        
    }
    
    //function to move self player
    func moveSelfTowards(_ direction: Vector2) {
        
        //check if current device is controlling a player
        if let p = self.selfPlayer {
            let vec = RTSGame.movementSpeed * direction.normalized()
            movePlayer(p, by: vec)
            self.commDelegate?.playerDidMove(p, to: p.getPosition())
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
                let diff:Vector2 = otherPlayer.getPosition() - player.getPosition()
                disgustVect = disgustVect + 1/(diff.length()*diff.length()) * diff
            }
            let vec = -RTSGame.movementSpeed * disgustVect
            movePlayer(player, by: vec)
        }
        
    }
    func movePlayer(_ p: Player, by vec:Vector2){
        
        if vec.isZero() {return}
        let oldPos = p.getPosition()
        p.moveBy(vec)
        self.delegate?.game(self, player: p, didMoveTo: p.getPosition(), from: oldPos)
        
    }
    
}
