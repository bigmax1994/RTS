//
//  Animation.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 03.04.24.
//

import Foundation

protocol Animatable {
    func update(timeSinceLastUpdate: Float) -> Bool
}

class Animation<T: Interpolatable>: Animatable {
    let duration:Float //duration in seconds
    var t:Float = 0 //progress of the animation
    
    let change: (T, T, (T) -> Void)
    
    let interpolFunction: InterpolationFunction<T>
    let secondOrderDynamics: SecondOrderDynamics<T>?
    
    init(duration: Float, change: (T, T, (T) -> Void), interpolationFunction: InterpolationFunction<T> = .linear, secondOrderConstants: (Float, Float, Float)? = nil){
        self.duration = duration
        self.change = change
        self.interpolFunction = interpolationFunction
        
        if let constants = secondOrderConstants {
            self.secondOrderDynamics = SecondOrderDynamics(start: change.0, f: constants.0, z: constants.1, r: constants.2)
        }else{
            self.secondOrderDynamics = nil
        }
        
    }
    
    func update(timeSinceLastUpdate: Float) -> Bool {
        
        self.t += timeSinceLastUpdate
        
        var x = interpolFunction.interpolate(from: change.0, to: change.1, at: self.t / self.duration)
        
        //if second order dynamics is set update using that value
        var secondOrderHasClamped = true
        if let secondOrderDynamics = self.secondOrderDynamics {
            (x, secondOrderHasClamped) = secondOrderDynamics.update(to: x, timeSinceLastUpdate: timeSinceLastUpdate)
        }
        
        change.2(x)
        
        if self.t > self.duration && secondOrderHasClamped {
            return true
        }
        return false
    }
    
    func setT(_ t:Float=0){
        self.t = t
    }
}
