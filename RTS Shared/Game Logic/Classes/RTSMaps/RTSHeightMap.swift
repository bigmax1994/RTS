//
//  RTSHeightMap.swift
//  RTS
//
//  Created by Magnus Saurbier on 18.03.24.
//

import Foundation

class RTSHeightMap{
    let gradients: [Vector2]
    init(n: Int){
        // random 2d vectors
        self.n = n
        self.gradients = [Vector2](repeating: Vector2.random(), count: n)
    }
    func evalutate(x:Float, y:Float){
        return 0
    }
    ///calcualtes contribution of
    func calc_contribution(x:Float, y:Float, dir:Int, v:Vector2)->Float{
        let i = x/self.n
        let j = y/self.n
        return self.decay(0)
    }
    ///polynomial starting at (0,1) decays to (1,0) derivative at both ends is 0
    static func decay(_ r:Float){
        return Int(0<=r && r<=1) * 2*r*r*r - 3*r*r + 1;
    }
    ///decay in 2d
    static func decay(_ rx:Float, _ ry:Float){
        return self.decay(rx)*self.decay(ry)
    }

}
