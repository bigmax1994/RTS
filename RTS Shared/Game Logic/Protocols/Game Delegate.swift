//
//  Game Delegate.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 05.03.24.
//

import Foundation

protocol GameDelegate {
    
    func gameDidStart(_ game: Game)
    
    func gameDidRecievePlayerAction(_ game: Game, from player: Player)
    
    func gameDidEnd(_ game: Game)
    
}
