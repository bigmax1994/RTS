//
//  AnimationQueue.swift
//  RTS
//
//  Created by Magnus Saurbier on 29.03.24.
//

import Foundation
import simd

class AnimationSet {
    
    var animations:[Animatable] = []
    
    func update(timeSinceLastUpate:Float){
        for (i, animation) in animations.enumerated().reversed() {
            if animation.update(timeSinceLastUpdate: timeSinceLastUpate) {
                
                animations.remove(at: i)
                
            }
        }
    }
    
    func addAnimation<T : Interpolatable>(to end: T, from start: T? = nil, for pointer: UnsafeMutablePointer<T>, time: Float, interpolationFunction: InterpolationFunction<T> = .linear, secondOrderConstants: (Float, Float, Float)? = nil) {
        
        let start = start ?? pointer.pointee
        
        let completion:(T) -> Void = { v in
            pointer.pointee = v
        }
        
        let anim:Animation<T> = Animation(duration: time, change: (start, end, completion), interpolationFunction: interpolationFunction, secondOrderConstants: secondOrderConstants)
        self.animations.append(anim)
        
    }
    
    func addAnimation<T : Interpolatable>(to end: T, from start: T, callback: @escaping (T) -> Void, time: Float, interpolationFunction: InterpolationFunction<T> = .linear, secondOrderConstants: (Float, Float, Float)? = nil) {
        
        let anim:Animation<T> = Animation(duration: time, change: (start, end, callback), interpolationFunction: interpolationFunction, secondOrderConstants: secondOrderConstants)
        self.animations.append(anim)
        
    }
    
    /*func addAnimation(to end: Animatable, from start: Animatable? = nil, for pointer: inout Float, time: Float) {
        
        let changes:[(Float, Float, (Float) -> Void)] = [makeChange(to: end, from: start, for: &pointer, time: time)]
        
        let anim = Animation(duration: time, changes: changes)
        self.animations.append(anim)
        
    }
    
    func addAnimation(to end: Vector2, from start: Vector2? = nil, for pointer: inout Vector2, time: Float) {
        
        let changes:[(Float, Float, (Float) -> Void)] = [makeChange(to: end.x, from: start?.x, for: &pointer.x, time: time),
                                                         makeChange(to: end.y, from: start?.y, for: &pointer.y, time: time)]
        
        let anim = Animation(duration: time, changes: changes)
        self.animations.append(anim)
        
    }
    
    func addAnimation(to end: Vector3, from start: Vector3? = nil, for pointer: inout Vector3, time: Float) {
        
        let changes:[(Float, Float, (Float) -> Void)] = [makeChange(to: end.x, from: start?.x, for: &pointer.x, time: time),
                                                         makeChange(to: end.y, from: start?.y, for: &pointer.y, time: time),
                                                         makeChange(to: end.z, from: start?.z, for: &pointer.z, time: time)]
        
        let anim = Animation(duration: time, changes: changes)
        self.animations.append(anim)
        
    }
    
    func addAnimation(to end: Vector3, from start: Vector3? = nil, for pointer: inout simd_float3, time: Float) {
        
        /*let change1 = withUnsafePointer(to: pointer.pointee.x, { xPoint in
            return makeChange(to: end.x, from: start?.x, for: xPoint, time: time)
        })
        let change2 = withUnsafePointer(to: pointer.pointee.y, { yPoint in
            return makeChange(to: end.y, from: start?.y, for: yPoint, time: time)
        })
        let change3 = withUnsafePointer(to: pointer.pointee.z, { zPoint in
            return makeChange(to: end.z, from: start?.z, for: zPoint, time: time)
        })*/
        let change1 = makeChange(to: end.x, from: start?.x, for: &pointer.x, time: time)
        let change2 = makeChange(to: end.y, from: start?.y, for: &pointer.y, time: time)
        let change3 = makeChange(to: end.z, from: start?.z, for: &pointer.z, time: time)
        
        let changes:[(Float, Float, (Float) -> Void)] = [change1, change2, change3]
        
        let anim = Animation(duration: time, changes: changes)
        self.animations.append(anim)
        
    }*/
    
}
