//
//  RTSHeightMap.swift
//  RTS
//
//  Created by Magnus Saurbier on 18.03.24.
//

import Foundation

class Heights{
    static func crater(v:Vector2) -> Float{
        return RTSGame.mapSettings.craterHeight*(1-(1-craterWall(v.x))*(1-craterWall(v.y)))
    }
    static func crater_grad(v:Vector2) -> Vector2{
        return RTSGame.mapSettings.craterHeight*Vector2(x: craterWall_diff(v.x)*(1-craterWall(v.y)), y: (1-craterWall(v.x))*craterWall_diff(v.y))
    }
    static func sigmoid(_ t:Float)->Float{
        return 1/(1+exp(-t))
    }
    static func sigmoid_diff(_ t:Float)->Float{
        return 1/(exp(t)+2+exp(-t))
    }
    static func craterWall(_ t:Float)->Float{
        sigmoid(RTSGame.mapSettings.craterSharpness*(t*t - RTSGame.mapSettings.craterWidth*RTSGame.mapSettings.craterWidth))
    }
    static func craterWall_diff(_ t:Float)->Float{
        sigmoid_diff(RTSGame.mapSettings.craterSharpness*(t*t - RTSGame.mapSettings.craterWidth*RTSGame.mapSettings.craterWidth)) * RTSGame.mapSettings.craterSharpness * 2*t
    }
    static func normalize(h:Float) -> Float{ //smushes the height function so that more space will fall into the specified HeightLevels. Returns h in (-1,1)
        var value:Float = 0
        var used:Float = 0
        for (height, beginsAt, sharpness) in RTSGame.mapSettings.heightLevels{
            let diff = height-used
            value += diff*sigmoid(sharpness*(h-beginsAt))
            used += diff
        }
        return value * 2 - 1
    }
    static func normalize_diff(h:Float) -> Float{
        var value:Float = 0
        var used:Float = 0
        for (height, beginsAt, sharpness) in RTSGame.mapSettings.heightLevels{
            let diff = height-used
            value += diff*sigmoid_diff(sharpness*(h-beginsAt))
            used += diff
        }
        return value * 2
    }
    static func sealevel(h:Float)-> Float{
        return max(RTSGame.mapSettings.sealevel-0.01, h)
    }
    static func polish(h:Float, v:Vector2) -> Float{
        var x = h
        //x = x + crater(v: v)
        x = normalize(h: x)
        //x = sealevel(h: x)
        return x
    }
    static func polish_grad(h:Float, grad:Vector2, v:Vector2) -> Vector2{
        if h < 0 {return Vector2()}
        var x = grad
        x = x + crater_grad(v: v)
        x = normalize_diff(h: h) * grad
        return x
    }
}
class MyRNG:RandomNumberGenerator{
    init(seed: Int) { srand48(seed) }
    func next() -> UInt64 { return UInt64(drand48() * Double(UInt64.max)) }
}
class RTSHeightMap{
    let n: Int
    var layers: [(RTSHeightMapLayer, Float)] = []//Layer, amplitude
    var min:Float = 0
    var max:Float = 0
    init(n:Int){
        ///MARK: TAKES DATA AND CONVERTS IT BACK TO ORIGINAL OBJET FOR SOME REASON (THIS FAILES)
        let data:Data = RTSGame.mapSettings.data
        print(data.base64EncodedString())
        let settings:MapSettings = RTSGame.mapSettings//MapSettings(data)
        print(settings.nPosts)
        var rng:RandomNumberGenerator = MyRNG(seed:0)
        self.n = n
        for (nPost, amplitude) in RTSGame.mapSettings.nPosts.enumerated().map({ (i, nPost) in
            return (nPost, RTSGame.mapSettings.amplitudes[i])
        }) {
            self.layers.append((RTSHeightMapLayer(n:nPost, using: &rng), amplitude))
        }
    }
    func evaluate(v:Vector2) -> (Float, Vector2){
        var sum:Float = 0.0
        var grad:Vector2 = Vector2()
        for (layer, amplitude) in self.layers{
            let (height, gradient) = layer.evaluate(v: v)
            sum += amplitude*height
            grad = grad + amplitude*gradient
        }
        let h = Heights.polish(h:sum, v:v)
        let g = Heights.polish_grad(h: h, grad: grad, v: v)
        if h<min{min=h}
        if h>max{max=h}
        return (h, grad)
    }
}

class RTSHeightMapLayer{
    let gradients: [Vector2]
    let n: Int
    let tileSize:Float
    init(n: Int, using rng: inout RandomNumberGenerator){
        // random 2d vectors
        self.n = n
        self.tileSize = 2/Float(n+1)
        self.gradients = [Vector2](repeating: Vector2(), count: n*n).map({ _ in Vector2.random(using: &rng)})

    }
    func coords_to_index(v:Vector2) -> (Int, Int){
        let a = Float(self.n+1) / Float(2)
        let i = Int(a * (v.x + 1)) - 1
        let j = Int(a * (v.y + 1)) - 1
        return (i,j)
    }
    func evaluate(v: Vector2) -> (Float, Vector2){
        var sum:Float = 0
        var gradient:Vector2 = Vector2()
        let (i,j):(Int, Int) = self.coords_to_index(v: v)
        if (i>1) {return (0, Vector2())}
        if (j>2) {return (0, Vector2())}
        if (i<1) {return (0, Vector2())}
        if (j<2) {return (0, Vector2())}
        let grad_pos = Float(2)/Float(n+1) * Vector2(x:Float(i+1), y:Float(j+1)) - Vector2.UP - Vector2.RIGHT
        
        if i>=0 && i<n && j>=0 && j<n{
            let (h,g) = self.calc_contribution(v: v, grad_pos:grad_pos, gradient:self.gradients[i*n+j])
            sum += h
            gradient = gradient + g
        }
        if i<n-1 && j>=0 && j<n{
            let (h,g) = self.calc_contribution(v:v, grad_pos:grad_pos+tileSize*Vector2.RIGHT, gradient:self.gradients[(i+1)*n+j])
            sum += h
            gradient = gradient + g
        }
        if i>=0 && i<n && j<n-1{
            let (h,g) = self.calc_contribution(v: v, grad_pos:grad_pos+tileSize*Vector2.UP, gradient:self.gradients[i*n+j+1])
            sum += h
            gradient = gradient + g
        }
        if i<n-1 && j<n-1{
            let (h,g) = self.calc_contribution(v:v, grad_pos:grad_pos+tileSize*(Vector2.RIGHT+Vector2.UP), gradient:self.gradients[(i+1)*n+j+1])
            sum += h
            gradient = gradient + g
        }
        return (sum, gradient)
    }
    ///calcualtes contribution of a given gradient to the evaluation at v
    func calc_contribution(v: Vector2, grad_pos:Vector2, gradient: Vector2)->(Float, Vector2){
        let d:Vector2 = Float(n+1)/Float(2) * (v - grad_pos)
        let decay = RTSHeightMapLayer.decay(d: d)
        let decay_diff = RTSHeightMapLayer.decay_diff(d.length()) * decay / d.length()
        return (decay * (d ** gradient), decay_diff * gradient)
    }
    ///polynomial starting at (0,1) decays to (1,0) derivative at both ends is 0
    static func decay(_ r:Float) -> Float {
        //let f:Float = 0<=r && r<=1 ? 1 : 0
        let square:Float = r*r
        let lambda:Float = 1 * (2 * r * square - 3 * square + 1)
        return lambda;
    }
    static func decay_diff(_ r:Float) -> Float {
        let lambda:Float = 6*r*r - 6*r
        return lambda
    }
    ///decy in 2d
    static func decay(d: Vector2) -> Float {
        return RTSHeightMapLayer.decay(abs(d.x)) * RTSHeightMapLayer.decay(abs(d.y))
    }
}
