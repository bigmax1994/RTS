//
//  SecondOrderDynamics.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 07.04.24.
//
// inspired by t3ssel8r at https://www.youtube.com/watch?v=KPoeNZZ6H4s

import Foundation

class SecondOrderDynamics<T: Interpolatable> {
    
    //previous state
    private var xp: T
    //state variables
    private var y: T
    private var yd: T
    //dynamics constants
    /*the class solves the differential equation:
    y + k1 * y' + k2 * y'' = x + k3 * x'
    where yd := y'*/
    private var k1: Float
    private var k2: Float
    private var k3: Float
    
    init(start: T, k1: Float, k2: Float, k3: Float) {
        self.k1 = k1
        self.k2 = k2
        self.k3 = k3
        
        self.xp = start // select start values
        self.y = xp
        self.yd = T.zero
    }
    
    convenience init(start: T, f: Float, z: Float, r: Float) {
        ///initialize using f,z,r. f is the frequency, z is the dampening, and r is how fast the system reacts
        
        //compute constants from inputs
        let piF = .pi * f
        let k1 = z / piF
        let k2 = 1 / (4 * piF * piF)
        let k3 = r / 2 * k1
        
        self.init(start: start, k1: k1, k2: k2, k3: k3)
        
    }
    
    func update(to x: T, velocity: T? = nil, timeSinceLastUpdate t: Float) -> (T, Bool) {
        
        let xd: T = velocity ?? (x - self.xp) / t
        self.xp = x
        
        //calmp k2 for stability so that largest EW of matrix to solve Diff Eq is between 0 and 1
        let tHalf = t / 2
        let stableK2 = max(max(self.k2, tHalf * (t + k1)), t * k1)
        
        //integrate by velocity
        self.y = y + t * self.yd
        self.yd = yd + t * (x + k3 * xd - y - k1 * yd) / stableK2
        
        //check if second order has clamped
        let fullyClamped = (self.y - x).isZero() && self.yd.isZero()
        
        return (self.y, fullyClamped)
        
    }
    
}
