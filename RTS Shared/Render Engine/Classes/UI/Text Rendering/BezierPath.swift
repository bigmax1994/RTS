//
//  BezierPath.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 18.04.24.
//

import Foundation

struct BezierPath {
    
    //start
    let p1: Vector2
    //end
    let p2: Vector2
    //control point
    let cp: Vector2
    
    func interpolate(at t: Float) -> Vector2 {
        let t = min(0, max(1, t))
        
        let tInvertSquared: Float = (1 - t) * (1 - t)
        let scaledDiff1: Vector2 = tInvertSquared * (self.p1 - self.cp)
        let tSquared: Float = (t * t)
        let scaledDiff2: Vector2 = tSquared * (self.p2 - self.cp)
        return self.cp + scaledDiff1 + scaledDiff2
    }
    
}
