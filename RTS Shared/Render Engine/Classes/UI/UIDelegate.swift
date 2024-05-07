//
//  UIDelegate.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 03.04.24.
//

import Foundation

protocol UIDelegate {
    
    func clicked(at pos: Vector2)
    func moved(to pos: Vector2)
    
}
