//
//  Interpolatable.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 04.04.24.
//

import Foundation

internal protocol Interpolatable {
    
    static func + (rhs: Self, lhs: Self) -> Self
    static func - (rhs: Self, lhs: Self) -> Self
    static func * (rhs: Float, lhs: Self) -> Self
    static func / (rhs: Self, lhs: Float) -> Self
    
    static var zero: Self { get }
    
    var magnitude: Float { get }
    
}

extension Interpolatable {
    
    func isZero() -> Bool {
        
        return (self - Self.zero).magnitude < 3 * Float.ulpOfOne
        
    }
    
}

