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
    
}

enum RTSActionType: UInt8 {
    case playerMove = 0
    case playerPlaceFence = 1
    case playerFireOn = 2
    
    static func initActionFrom(_ data: Data) -> RTSGameAction {
        
        let RTSData = RTSActionData(data: data)
        let type = RTSData.getActionType()
        
        switch type {
        case .playerMove:
            fatalError("not implemented")
        case .playerPlaceFence:
            fatalError("not implemented")
        case .playerFireOn:
            fatalError("not implemented")
        default:
            fatalError("unknown type")
        }
        
    }
    
}
