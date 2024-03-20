//
//  GPUEncodable.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 20.03.24.
//

import Foundation

protocol GPUEncodable { }

extension GPUEncodable {
    
    static func bufferSize(count elements: Int) -> Int {
        return MemoryLayout<Self>.size * elements
    }
    
    static func bufferStride(count elements: Int) -> Int {
        return MemoryLayout<Self>.stride * elements
    }
    
}
