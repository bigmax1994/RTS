//
//  RTSPlayerMoveAction.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 08.03.24.
//

import Foundation

class RTSPlayerMoveAction: RTSGameAction {
    
    var uuid: UUID
    var pos: Vector2
    
    init(uuid: UUID, position: Vector2) {
        self.uuid = uuid
        self.pos = position
    }
    
    func checkCompatibility(with game: RTSGame) -> Bool {
        
        if game.players[uuid] == nil {
            return false
        }
        
        if !game.players[uuid]!.isFree {
            return false
        }
        
        if !game.map.checkIfPositionIsInBounds(pos) {
            return false
        }
        
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
        var data = self.uuid.data
        data.append(self.pos.data)
        return data
    }
    
    required init(_ data: Data) {
        
        let uuidData = data.subdata(in: 0..<UUID.byteSize)
        let posData = data.subdata(in: UUID.byteSize..<UUID.byteSize + Vector2.byteSize)
        
        self.uuid = UUID(uuidData)
        self.pos = Vector2(posData)
        
    }
    
}
