//
//  RTSHeightMap.swift
//  RTS
//
//  Created by Magnus Saurbier on 18.03.24.
//

import Foundation

class Heights{
    static let craterWidth:Float = 0.9
    static let craterHeight:Float = 2
    static let craterSharpness:Float = 6.5
    static let heightLevels:[(height:Float, beginsAt:Float, sharpness:Float)] = [(0.37, -0.8, 7), (0.51, 0.45, 9), (1, 0.95, 4)] //Heightlevels, which will be more present in the Heightmap
    static func crater(v:Vector2) -> Float{
        return craterHeight*(1-(1-craterWall(v.x))*(1-craterWall(v.y)))
    }
    static func sigmoid(_ t:Float)->Float{
        return 1/(1+exp(-t))
    }
    static func craterWall(_ t:Float)->Float{
        sigmoid(craterSharpness*(t*t - craterWidth*craterWidth))
    }
    static func normalize(h:Float) -> Float{ //smushes the height function so that more space will fall into the specified HeightLevels. Returns h in (-1,1)
        var value:Float = 0
        var used:Float = 0
        for (height, beginsAt, sharpness) in Heights.heightLevels{
            let diff = height-used
            value += diff*sigmoid(sharpness*(h-beginsAt))
            used += diff
        }
        return value * 2 - 1
    }
    static func sealevel(h:Float)-> Float{
        return max(RTSMap.sealevel-0.01, h)
    }
    static func polish(h:Float, v:Vector2) -> Float{
        var x = h
        x = x + crater(v: v)
        x = normalize(h: x)
        x = sealevel(h: x)
        return x
    }
}
class RTSHeightMap{
    let n: Int
    var layers: [(RTSHeightMapLayer, Float)] = []//Layer, amplitude
    var min:Float = 0
    var max:Float = 0
    let upshift:Float = 0.0
    let amplitudes:[Float]=[2.5, 1.3, 0.57, 0.08]
    let nPosts:[Int]=[3, 7, 23, 91]
    init(n:Int){
        self.n = n
        for (nPost, amplitude) in nPosts.enumerated().map({ (i, nPost) in
            return (nPost, amplitudes[i])
        }) {
            self.layers.append((RTSHeightMapLayer(n:nPost), amplitude))
        }
    }
    func evaluate(v:Vector2) -> Float{
        var sum:Float = 0.0
        for (layer, amplitude) in self.layers{
            sum += amplitude*layer.evaluate(v: v)
        }
        return Heights.polish(h:sum, v:v)
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
        let a = Float(self.n+1) / Float(2)
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
        //let f:Float = 0<=r && r<=1 ? 1 : 0
        let square:Float = r*r
        let lambda:Float = 1 * (2 * r * square - 3 * square + 1)
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
