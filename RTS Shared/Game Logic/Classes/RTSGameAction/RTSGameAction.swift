//
//  RTSGameAction.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 08.03.24.
//

import Foundation

protocol RTSGameAction {
    
    func checkCompatibility(with game: RTSGame) -> Bool
    
    func applyAction(to game: RTSGame) -> Bool
    
    func encode() -> Data
    init(from data: Data)
    
}
