//
//  InterpolationFunction.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 03.04.24.
//

import Foundation

enum InterpolationFunction<T: Interpolatable> {
    
    case linear
    
    func interpolate(from start: T, to end: T, at t: Float) -> T {
        
        let t = max(min(t, 1), 0)
        
        switch self {
        case .linear:
            let v = start + t * (end - start)
            print("linearly interpolated from=\(start), to=\(end), at t=\(t), result: \(v)")
            return v
        }
    }
    
}
