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
            player.moveTo(map.distributePlayer(target: Vector2()))
        }
        
    }
    
    //function to move player
    func move(_ direction: Vector2) {
        
        //check if current device is controlling a player
        if let p = self.selfPlayer {
            
            //get relative direction to player position
            let relativeDirection = direction - p.getPosition()
            
            //get movement vector from movement speed
            let vec = RTSGame.movementSpeed * relativeDirection.normalized()
            
            //move the player
            p.moveBy(vec)
            
            //send info to delegates
            self.delegate?.playerDidMove(self, player: p, to: p.getPosition())
            self.commDelegate?.playerDidMove(p, to: p.getPosition())
            
        }
        
    }
    
}
