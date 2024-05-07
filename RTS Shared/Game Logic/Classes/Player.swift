//
//  Player.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 05.03.24.
//

import Foundation

class Player: Equatable {
    
    static func == (lhs: Player, rhs: Player) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    var name: String
    var uuid: UUID
    
    var isFree: Bool = true
    
    internal var position: Vector2 = Vector2()
    
    var playerChar: Object? = nil
    
    init(name: String) {
        self.name = name
        self.uuid = UUID()
    }
    
    func moveBy(_ vec: Vector2) {
        position = position + vec
    }
    func moveTo(_ pos: Vector2) {
        position = pos
    }
    func getPosition() -> Vector2 {
        return self.position
    }
    
}
