//
//  RTSGame.swift
//  RTS iOS
//
//  Created by Max Gasslitter Strobl on 05.03.24.
//

import Foundation

class RTSGame {
    
    var delegate: RTSGameDelegate?
    var players: [Player]
    var map: RTSMap
    
    //function to initialize the game
    init(delegate: RTSGameDelegate? = nil, players: [Player], map: RTSMap) {
        self.delegate = delegate
        self.players = players
        self.map = map
    }
    
    //function to start the game
    func startGame() {
        //reset the map
        map.reset()
        
        //determine player starting positions
        for player in players {
            player.position = map.distributePlayer()
        }
        
    }
    
    func move(_ direction: Vector) {
        let vec = direction.normalized()
        
        
        
    }
    
}
