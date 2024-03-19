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
    func evaluate(v: Vector2) -> Float{
        let sum = 0
        let i = Int((x+1)/2*self.n)
        let j = Int((y+1)/2*self.n)
        let grad_pos = Vector2(x:(Float(i)/self.n)*2-1, y:(Float(j)/self.n)*2-1)
        
        if i>=0 && j>=0{
            sum += self.calc_contribution(v: v, grad_pos:grad_pos, gradient:self.gradients[i*n+j])
        }
        if i<n && j>=0{
            sum += self.calc_contribution(v:v, grad_pos:grad_pos+Vector2.DOWN, gradient:self.gradients[(i+1)*n+j])
        }
        if i>=0 && j<n{
            sum += self.calc_contribution(v: v, grad_pos:grad_pos+Vector2.RIGHT, gradient:self.gradients[i*n+j+1])
        }
        if i<n && j<0{
            sum += self.calc_contribution(v:v, grad_pos:grad_pos+Vector2.RIGHT+Vector2.DOWN, gradient:self.gradients[(i+1)*n+j+1])
        }
        
        
    }
    func evalutate(x:Float, y:Float) -> Float{
        return self.evaluate(v: Vector2(x:x, y:y))
    }
    ///calcualtes contribution of a given gradient to the evaluation at v
    func calc_contribution(v: Vector2, grad_pos:Vector2, gradient: Vector2)->Float{
        let d = v - grad_pos
        return self.decay(d) * d*gradient
    }
    ///polynomial starting at (0,1) decays to (1,0) derivative at both ends is 0
    static func decay(_ r:Float){
        return Int(0<=r && r<=1) * 2*r*r*r - 3*r*r + 1;
    }
    ///decy in 2d
    static func decay(d: Vector2){
        return self.decay(d.x, d.y)
    }
    ///decay in 2d
    static func decay(_ dx:Float, _ dy:Float){
        return self.decay(abs(dx))*self.decay(abs(dy))
    }

}
