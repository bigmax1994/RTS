//
//  Player.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 05.03.24.
//

import Foundation

class Player {
    
    var name: String
    var uuid: UUID
    
    var position: Vector = Vector()
    
    init(name: String) {
        self.name = name
        self.uuid = UUID()
    }
}
