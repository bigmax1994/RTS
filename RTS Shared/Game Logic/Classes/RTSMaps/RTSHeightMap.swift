//
//  RTSHeightMap.swift
//  RTS
//
//  Created by Magnus Saurbier on 18.03.24.
//

import Foundation

class RTSHeightMap{
    let gradients: [Vector2]
    let n: Int
    let tileSize:Float
    init(n: Int){
        // random 2d vectors
        self.n = n
        self.tileSize = 2/Float(n+1)
        self.gradients = [Vector2](repeating: Vector2(), count: n*n).map({ _ in Vector2.random()})

    }
    func evaluate(v: Vector2) -> Float{
        var sum:Float = 0
        let a = Float((self.n+1) / 2)
        let i = Int(a * (v.x + 1)) - 1
        let j = Int(a * (v.y + 1)) - 1
        
        let grad_pos = Float(2)/Float(n+1) * Vector2(x:Float(i+1), y:Float(j+1)) - Vector2.UP - Vector2.RIGHT
        
        if i>=0 && i<n && j>=0 && j<n{
            sum += self.calc_contribution(v: v, grad_pos:grad_pos, gradient:self.gradients[i*n+j])
        }
        if i<n-1 && j>=0 && j<n{
            sum += self.calc_contribution(v:v, grad_pos:grad_pos+tileSize*Vector2.RIGHT, gradient:self.gradients[(i+1)*n+j])
        }
        if i>=0 && i<n && j<n-1{
            sum += self.calc_contribution(v: v, grad_pos:grad_pos+tileSize*Vector2.UP, gradient:self.gradients[i*n+j+1])
        }
        if i<n-1 && j<n-1{
            sum += self.calc_contribution(v:v, grad_pos:grad_pos+tileSize*(Vector2.RIGHT+Vector2.UP), gradient:self.gradients[(i+1)*n+j+1])
        }
        return 0.5*sum + 5
        
    }
    func evalutate(x:Float, y:Float) -> Float{
        return self.evaluate(v: Vector2(x:x, y:y))
    }
    ///calcualtes contribution of a given gradient to the evaluation at v
    func calc_contribution(v: Vector2, grad_pos:Vector2, gradient: Vector2)->Float{
        
        let d:Vector2 = Float(n+1)/Float(2) * (v - grad_pos)
        return (d ** gradient) * RTSHeightMap.decay(d: d)
    }
    ///polynomial starting at (0,1) decays to (1,0) derivative at both ends is 0
    static func decay(_ r:Float) -> Float {
        let f:Float = 0<=r && r<=1 ? 1 : 0
        let square:Float = r*r
        let lambda:Float = f * 2 * r * square - 3 * square + 1
        return lambda;
    }
    ///decy in 2d
    static func decay(d: Vector2) -> Float {
        return RTSHeightMap.decay(d.x, d.y)
    }
    ///decay in 2d
    static func decay(_ dx:Float, _ dy:Float) -> Float {
        return RTSHeightMap.decay(abs(dx)) * RTSHeightMap.decay(abs(dy))
    }
    
    func makeMatrix() -> Matrix{
        let k = 10
        var M:Matrix = Matrix(columns:10, rows:10)
        for i in 0..<k{
            for j in 0..<k{
                let pos = Vector2(x:Float(2*i)/Float(k)-1, y:Float(2*j)/Float(k)-1)
                print("(\(pos)): \(self.evaluate(v: pos))")
                M.elements[i*k+j] = self.evaluate(v: pos)
            }
        }
        return M
    }

}
