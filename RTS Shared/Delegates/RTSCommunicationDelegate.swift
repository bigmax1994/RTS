//
//  RTSCommunicationDelegate.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 08.03.24.
//

import Foundation
import Network
import MultipeerConnectivity

class RTSCommunicationDelegate: NSObject {
    
    //var connection: NWConnection!
    
    var session: MCSession
    
    var game: RTSGame?
    
    override init() {
        
        print("comm del init")
        
        let peer = MCPeerID(displayName: game?.selfPlayer?.name ?? "N/A")
        self.session = MCSession(peer: peer)
        
        let advertiser = MCAdvertiserAssistant(serviceType: "RTS-Game", discoveryInfo: nil, session: self.session)
        let browser = MCNearbyServiceBrowser(peer: peer, serviceType: "RTS-Game")
        
        super.init()
        
        session.delegate = self
        advertiser.delegate = self
        browser.delegate = self
        
        advertiser.start()
        browser.startBrowsingForPeers()
        
        /*let host: NWEndpoint.Host = "131.159.208.167"
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
            print("hello")
            if (isComplete) {
                if let data = content {
                    if let action = RTSActionData.initActionFrom(data) {
                        self.didRecieve(action)
                    }
                }
            }
        }*/
        
    }
    
    func playerDidMove(_ player: Player, to position: Vector2) {
        
        let action = RTSPlayerMoveAction(uuid: player.uuid, position: player.getFuturePosition())
        send(action)
        
    }
    
    func send(_ action: RTSGameAction) {
        let data = action.data
        //connection.send(content: data, completion: .idempotent)
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

extension RTSCommunicationDelegate: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("ServiceAdvertiser didNotStartAdvertisingPeer: \(String(describing: error))")
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        NSLog("didReceiveInvitationFromPeer \(peerID)")
    }
}

extension RTSCommunicationDelegate: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("ServiceBrowser didNotStartBrowsingForPeers: \(String(describing: error))")
    }

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        NSLog("ServiceBrowser found peer: \(peerID)")
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("ServiceBrowser lost peer: \(peerID)")
    }
}

extension RTSCommunicationDelegate: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        NSLog("peer \(peerID) didChangeState: \(state.rawValue)")
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        NSLog("didReceive bytes \(data.count) bytes")
    }

    public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("Receiving streams is not supported")
    }

    public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        NSLog("Receiving resources is not supported")
    }

    public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        NSLog("Receiving resources is not supported")
    }
}

extension RTSCommunicationDelegate: MCAdvertiserAssistantDelegate {
    
}
