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
    var players: [Player]
    var selfPlayer: Player?
    var map: RTSMap
    
    //function to initialize the game
    init(players: [Player], map: RTSMap, selfPlayer: Player? = nil, delegate: RTSGameDelegate? = nil, commDelegate: RTSCommunicationDelegate? = nil) {
        self.delegate = delegate
        self.commDelegate = commDelegate
        self.players = players
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
        for player in players {
            player.moveTo(map.distributePlayer())
        }
        
    }
    
    //function to move player
    func move(_ direction: Vector2) {
        
        //check if current device is controlling a player
        if let p = self.selfPlayer {
            
            let vec = RTSGame.movementSpeed * direction.normalized()
            
            p.moveBy(vec)
            
            self.delegate?.playerDidMove(self, player: p, to: p.getPosition())
            
        }
        
    }
    
}
