//
//  RTSGameDelegate.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 05.03.24.
//

import Foundation

protocol RTSGameDelegate {
    
    var mousePosition:Vector2 {get}
    var mouseIsDown:Bool {get}
    
    var game: RTSGame? { get set }
    
    func gameDidStart(_ game: RTSGame)
    
    func game(_ game: RTSGame, player: Player, didMoveTo position: Vector2, from oldPosition: Vector2)
    
    func gameDidEnd(_ game: RTSGame)
    
    func setGame(_ game: RTSGame)
    
    func userDidClick(on pos: Vector2)
    
}
