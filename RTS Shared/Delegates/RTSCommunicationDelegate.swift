//
//  RTSCommunicationDelegate.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 08.03.24.
//

import Foundation
import Network

class RTSCommunicationDelegate {
    
    var connection: NWConnection
    
    var game: RTSGame?
    
    init() {
        
        let host: NWEndpoint.Host = "131.159.194.191"
        let port: NWEndpoint.Port = 8461
        self.connection = NWConnection(host: host, port: port, using: .udp)
        
        connection.stateUpdateHandler = { (newState) in
            switch (newState) {
            case .preparing:
                NSLog("NWConnection entered state: preparing")
            case .ready:
                NSLog("NWConnection entered state: ready")
            case .setup:
                NSLog("NWConnection entered state: setup")
            case .cancelled:
                NSLog("NWConnection entered state: cancelled")
            case .waiting:
                NSLog("NWConnection entered state: waiting")
            case .failed:
                NSLog("NWConnection entered state: failed")
            default:
                NSLog("NWConnection entered an unknown state")
            }
        }
        
        connection.start(queue: .global())
        
        connection.receive(minimumIncompleteLength: 0, maximumLength: Int.max) { content, contentContext, isComplete, error in
            if (isComplete) {
                if let data = content {
                    if let action = RTSActionData.initActionFrom(data) {
                        self.didRecieve(action)
                    }
                }
            }
        }
        
    }
    
    func playerDidMove(_ player: Player, to position: Vector2) {
        
        let action = RTSPlayerMoveAction(uuid: player.uuid, position: player.getPosition())
        send(action)
        
    }
    
    func send(_ action: RTSGameAction) {
        let data = action.data
        connection.send(content: data, completion: .idempotent)
    }
    
    func didRecieve(_ action: RTSGameAction) {
        if let game = self.game {
            if !action.applyAction(to: game) {
                fatalError("failed to apply Action")
            }
        }
    }
    
    func setGame(_ game: RTSGame) {
        self.game = game
    }
    
}
