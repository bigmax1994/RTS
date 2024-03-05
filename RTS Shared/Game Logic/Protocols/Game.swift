//
//  Game.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 05.03.24.
//

import Foundation

protocol Game {
    
    var delegate: GameDelegate? {get set}
    var players: [Player] {get}
    
    var map: Map {get}
    
}
