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
    
    var isFree: Bool = true
    
    private var currentPosition: Vector2 = Vector2()
    private var futurePosition: Vector2 = Vector2()
    
    var playerChar: Object? = nil
    
    init(name: String) {
        self.name = name
        self.uuid = UUID()
    }
    func displayAt(_ pos: Vector2){
        currentPosition = pos
    }
    func moveBy(_ vec: Vector2) {
        futurePosition = futurePosition + vec
    }
    func moveTo(_ pos: Vector2) {
        futurePosition = pos
    }
    func getCurrentPosition() -> Vector2 {
        return self.currentPosition
    }
    func getFuturePosition() -> Vector2 {
        return self.futurePosition
    }
    
}
