//
//  Vector4.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 08.03.24.
//

import Foundation

struct Vector4: Byteable, Equatable {
    
    static var byteSize: Int = 4 * Float.byteSize
    
    var data: Data {
        var data = x.data
        data.append(y.data)
        data.append(z.data)
        data.append(t.data)
        
        return data
    }
    
    init(_ data: Data) {
        
        let xData = data.subdata(in: 0 ..< Float.byteSize)
        let yData = data.subdata(in: Float.byteSize ..< 2 * Float.byteSize)
        let zData = data.subdata(in: 2 * Float.byteSize ..< 3 * Float.byteSize)
        let tData = data.subdata(in: 3 * Float.byteSize ..< 4 * Float.byteSize)
        
        self.x = Float(xData)
        self.y = Float(yData)
        self.z = Float(zData)
        self.t = Float(tData)
        
    }
    
    var x: Float
    var y: Float
    var z: Float
    var t: Float
    
    init() {
        x = 0
        y = 0
        z = 0
        t = 0
    }
    
    init(x: Float, y: Float, z: Float, t: Float) {
        self.x = x
        self.y = y
        self.z = z
        self.t = t
    }
    
    init(alpha: Float, beta: Float, gamma: Float, length: Float = 1) {
        self.x = length * cos(alpha) * cos(beta) * cos(gamma)
        self.y = length * sin(alpha) * cos(beta) * cos(gamma)
        self.z = length * sin(beta) * cos(gamma)
        self.t = length * sin(gamma)
    }
    
    func toArray() -> [Float] {
        return [x,y,z,t]
    }
    
}
