//
//  RTSHeightMap.swift
//  RTS
//
//  Created by Magnus Saurbier on 18.03.24.
//

import Foundation

class RTSCrater{
    static let size:Float = 1.2
    static func evaluate(v:Vector2) -> Float{
        let x:Float = (v.x + RTSCrater.size)*(v.x - RTSCrater.size)
        let y:Float = (v.y + RTSCrater.size)*(v.y - RTSCrater.size)
        return -x*y + pow(size, 4)
    }
}
class RTSHeightMap{
    let n: Int
    var layers: [(RTSHeightMapLayer, Float)] //Layer, amplitude
    var min:Float
    var max:Float
    let upshift:Float = 0.0
    let steepness:Float = 4.0
    init(n:Int, amplitudes:[Float]=[1.2, 0.4, 0.02, 0.01], nPosts:[Int]=[3, 13, 57, 91]){
        self.n = n
        self.layers = []
        for (nPost, amplitude) in nPosts.enumerated().map({ (i, nPost) in
            return (nPost, amplitudes[i])
        }) {
            self.layers.append((RTSHeightMapLayer(n:nPost), amplitude))
        }
        self.min = 0
        self.max = 0
    }
    func evaluate(v:Vector2) -> Float{
        var sum:Float = 0.0
        for (layer, amplitude) in self.layers{
            sum += amplitude*layer.evaluate(v: v)
        }
        sum = sum*(1-upshift) + upshift/2
        sum = sum + RTSCrater.evaluate(v: v)
        sum = 1/(1+exp(-steepness*sum))
        sum = Swift.max(sum, RTSMap.sealevel-0.05)
        return sum
    }
}

class RTSHeightMapLayer{
    let gradients: [Vector2]
    let n: Int
    let tileSize:Float
    var min:Float
    var max:Float
    init(n: Int){
        // random 2d vectors
        self.n = n
        self.tileSize = 2/Float(n+1)
        self.gradients = [Vector2](repeating: Vector2(), count: n*n).map({ _ in Vector2.random()})
        self.min = 0
        self.max = 0

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
        if sum < min{min = sum}
        if sum > max{max = sum}
        return sum
        
    }
    func evalutate(x:Float, y:Float) -> Float{
        return self.evaluate(v: Vector2(x:x, y:y))
    }
    ///calcualtes contribution of a given gradient to the evaluation at v
    func calc_contribution(v: Vector2, grad_pos:Vector2, gradient: Vector2)->Float{
        
        let d:Vector2 = Float(n+1)/Float(2) * (v - grad_pos)
        return (d ** gradient) * RTSHeightMapLayer.decay(d: d)
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
        return RTSHeightMapLayer.decay(d.x, d.y)
    }
    ///decay in 2d
    static func decay(_ dx:Float, _ dy:Float) -> Float {
        return RTSHeightMapLayer.decay(abs(dx)) * RTSHeightMapLayer.decay(abs(dy))
    }
    
    func makeMatrix() -> Matrix{
        let k = 10
        var M:Matrix = Matrix(columns:10, rows:10)
        for i in 0..<k{
            for j in 0..<k{
                let pos = Vector2(x:Float(2*i)/Float(k)-1, y:Float(2*j)/Float(k)-1)
                M.elements[i*k+j] = self.evaluate(v: pos)
            }
        }
        return M
    }

}
