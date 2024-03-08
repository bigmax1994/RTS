//
//  RTSData.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 08.03.24.
//

import Foundation

struct RTSActionData {
    
    static let clientServerInfoRange:Range<Data.Index> = 0..<1
    static let actionTypeRange:Range<Data.Index> = 1..<2
    static let contentIndex:Data.Index = 2
    
    let data: Data
    
    func getActionType() -> RTSActionType? {
        
        let bytes = data.subdata(in: RTSActionData.actionTypeRange)
        
        let int: UInt8 = bytes.withUnsafeBytes { $0.load(as: UInt8.self) }
        
        return RTSActionType(rawValue: int)
        
    }
    
    func getContent() -> Data {
        return data.subdata(in: RTSActionData.contentIndex..<self.data.endIndex)
    }
    
    init(_ action: RTSGameAction) {
        
        let contentData = action.data
        let serverInfo:UInt8 = 0
        let actionType:UInt8 = RTSActionType.getActionType(action).rawValue
        
        var d = Data([serverInfo, actionType])
        d.append(contentData)
        
        self.data = d
        
    }
    
    init(_ data: Data) {
        self.data = data
    }
    
    static func initActionFrom(_ data: Data) -> RTSGameAction? {
        
        let RTSData = RTSActionData(data)
        return initActionFrom(RTSData)
        
    }
    
    static func initActionFrom(_ data: RTSActionData) -> RTSGameAction? {
        
        let type = data.getActionType()
        
        switch type {
        case .playerMove:
            return RTSPlayerMoveAction(data.data)
        case .playerPlaceFence:
            fatalError("not implemented")
        case .playerFireOn:
            fatalError("not implemented")
        default:
            return nil
        }
        
    }
    
}

enum RTSActionType: UInt8 {
    case playerMove = 0
    case playerPlaceFence = 1
    case playerFireOn = 2
    
    static func getActionType(_ action: RTSGameAction) -> RTSActionType {
    
        switch action {
        case is RTSPlayerMoveAction:
            return .playerMove
        default:
            fatalError("unknown action type")
        }
        
    }
    
}
