//
//  Encodable.swift
//  RTS iOS
//
//  Created by Max Gasslitter Strobl on 08.03.24.
//

import Foundation

protocol Byteable {
    
    static var byteSize: Int { get }
    var data: Data { get }
    
    init(_ data: Data)
    
}

extension Float: Byteable {
    var data: Data {
        Data(withUnsafeBytes(of: self, Array.init))
    }
    static let byteSize = 4
    
    init(_ data: Data) {
        self = data.withUnsafeBytes { $0.load(as: Float.self) }
    }
}

extension UUID: Byteable {
    
    func asUInt8Array() -> [UInt8]{
        let (u1,u2,u3,u4,u5,u6,u7,u8,u9,u10,u11,u12,u13,u14,u15,u16) = self.uuid
        return [u1,u2,u3,u4,u5,u6,u7,u8,u9,u10,u11,u12,u13,u14,u15,u16]
    }
    
    var data: Data {
        return Data(self.asUInt8Array())
    }
    
    static let byteSize = 16
    
    init(_ data: Data) {
        self = data.withUnsafeBytes{
            guard let baseAddress = $0.bindMemory(to: UInt8.self).baseAddress else {
                fatalError("failure to decode")
            }
            return NSUUID(uuidBytes: baseAddress) as UUID
        }
    }
    
}

