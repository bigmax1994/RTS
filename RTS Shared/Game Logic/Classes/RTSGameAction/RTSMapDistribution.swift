//
//  RTSGameDistribution.swift
//  RTS
//
//  Created by Magnus Saurbier on 03.04.24.
//

import Foundation

class RTSMapDistribution: RTSGameAction {
    
    let seed:UInt64
    let game:RTSGame
    
    init(seed:UInt64, game:RTSGame) {
        self.seed = seed
        self.game = game
    }
    
    func checkCompatibility(with game: RTSGame) -> Bool {
        return true
    }
    
    func applyAction(to game: RTSGame) -> Bool {
        
        if self.checkCompatibility(with: game) {
            game.players[uuid]?.moveTo(pos)
            return true
        }
        
        return false
        
    }
    
    static let byteSize: Int = UUID.byteSize + Vector2.byteSize
    
    var data: Data {
        var data = Data([0, RTSActionType.playerMove.rawValue])
        data.append(self.uuid.data)
        data.append(self.pos.data)
        return data
    }
    
    required init(_ data: Data) {
        
        let uuidData = data.subdata(in: 0..<UUID.byteSize)
        let posData = data.subdata(in: UUID.byteSize..<UUID.byteSize + Vector2.byteSize)
        
        self.seed = 0
        self.game = 
        
    }
    
}
