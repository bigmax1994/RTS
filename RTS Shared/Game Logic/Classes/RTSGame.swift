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
            player.moveTo(map.distributePlayer(target: Vector2()))
        }
        
    }
    func onTick(){
        let now = Date().timeIntervalSince1970
        self.animationQueue.update(timeSinceLastUpate: Float(now - lastUpdate))
        self.lastUpdate = now
    }
    
    //function to move player
    func move(_ direction: Vector2) {
        
        //check if current device is controlling a player
        if let p = self.selfPlayer {
            
            //get relative direction to player position
            //let relativeDirection = direction - p.getPosition()
            
            //get movement vector from movement speed
            let vec = RTSGame.movementSpeed * direction.normalized()
            
            //save old position
            let oldPos = p.getPosition()
            
            //move the player
            self.animationQueue.addMovement(to: oldPos+vec, p: p)
            p.moveBy(vec)
            
            
            //send info to delegates
            self.commDelegate?.playerDidMove(p, to: p.getPosition())
            
        }
        
    }
    func movementTick(from:Vector2, to:Vector2, p:Player){
        self.delegate?.playerDidMove(self, player: p, to: to, from: from)
    }
    
}
