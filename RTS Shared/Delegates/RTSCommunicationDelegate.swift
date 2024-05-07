//
//  RTSCommunicationDelegate.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 08.03.24.
//

import Foundation
import Network
import MetalKit

class RTSCommunicationDelegate {
    
    enum DeviceType {
        case server
        case client
    }
    
    static let service: NWListener.Service = NWListener.Service(applicationService: "RTS-Game")
    static let port: NWEndpoint.Port = 8461
    
    static let host: NWEndpoint.Host = "131.159.208.167"
    
    var type: DeviceType? = nil
    
    var connection: NWConnection? = nil
    
    var game: RTSGame? = nil
    
    var listener: NWListener? = nil
    var connections:[NWConnection] = []
    
    var selectScreen: World!
    
    var startGame: (() -> Void)?
    
    init(to view: MTKView, startGame: (() -> Void)?) {
        
        self.startGame = startGame
        
        guard let clientButton = Button(onClick: self.becomeClient, pos: Vector2(x: -1, y: -1), size: Vector2(x: 1, y: 2), color: Color.green, text: "Client") else { return }
        guard let serverButton = Button(onClick: self.becomeServer, pos: Vector2(x: 0, y: -1), size: Vector2(x: 1, y: 2), color: Color.red, text: "Server") else { return }
        
        self.selectScreen = World(ui: UI(objects: [clientButton, serverButton]))
        
    }
    
    func playerDidMove(_ player: Player, to position: Vector2) {
        
        let action = RTSPlayerMoveAction(uuid: player.uuid, position: player.getPosition())
        send(action)
        
    }
    
    func send(_ action: RTSGameAction) {
        let data = action.data
        print(data.base64EncodedString())
        connection?.send(content: data, completion: .idempotent)
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
    
    func becomeServer() {
        self.type = .server
        
        self.listener = try? NWListener(using: .udp, on: RTSCommunicationDelegate.port)
        guard let listener = self.listener else { return }
        listener.serviceRegistrationUpdateHandler = { (serviceChange) in
            switch serviceChange {
            case .add(let endpoint):
                switch endpoint {
                case let .service(name, _, _, _):
                    print("listening as name \(name)")
                default:
                    break
                }
            default:
                break
            }

        }
        listener.newConnectionHandler = { conn in
            conn.start(queue: .global())
            conn.receive(minimumIncompleteLength: 0, maximumLength: Int.max) { content, contentContext, isComplete, error in
                print("hello")
                if (isComplete) {
                    if let data = content {
                        if let action = RTSActionData.initActionFrom(data) {
                            self.didRecieve(action)
                        }
                    }
                }
            }
            self.connections.append(conn)
        }
        listener.start(queue: .global())
        
        if let start = self.startGame {
            start()
        }
        
    }
    
    func becomeClient() {
        self.type = .client
        
        self.connectToHost(RTSCommunicationDelegate.host)
        
    }
    
    func connectToHost(_ ip: NWEndpoint.Host) {
        
        self.connection = NWConnection(host: ip, port: RTSCommunicationDelegate.port, using: .udp)
        
        guard let connection = self.connection else { return }
        
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
            print("hello")
            if (isComplete) {
                if let data = content {
                    if let action = RTSActionData.initActionFrom(data) {
                        self.didRecieve(action)
                    }
                }
            }
        }
        
    }
    
}
