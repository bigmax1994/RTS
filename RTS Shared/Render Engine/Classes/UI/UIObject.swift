//
//  Clickable.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 03.04.24.
//

import Foundation

protocol UIObject: Drawable {}

protocol Clickable: UIObject {
    
    var onClick: () -> Void { get set }
    
    func isInside(_ pos: Vector2) -> Bool
    func clickAnimation() -> Animatable
    
}
