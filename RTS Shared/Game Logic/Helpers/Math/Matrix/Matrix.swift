//
//  Matrix.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 18.03.24.
//

import Foundation

struct Matrix {
    
    var elements: [Float]
    var columns: Int
    var rows: Int
    
    init(elements: [Float], columns: Int, rows: Int) {
        
        self.elements = elements
        self.columns = columns
        self.rows = rows
        
    }
    
    init(_ elements: [[Float]]) {
        
        self.elements = elements.reduce(into: [Float]()) { partialResult, r in
            partialResult.append(contentsOf: r)
        }
        self.columns = elements[0].count
        self.rows = elements.count
        
    }
    
    init(columns: Int, rows: Int) {
        
        self.elements = [Float](repeating: 0.0, count: columns * rows)
        self.columns = columns
        self.rows = rows
        
    }
    
    static func Identity(_ n: Int) -> Matrix {
        
        var m = Matrix(columns: n, rows: n)
        for i in 0...(n-1) {
            m[i, i] = 1
        }
        
        return m
        
    }
    
    subscript(row: Int, column: Int) -> Float {
        get {
            assert(indexIsValid(row: row, column: column), "Index out of range")
            return self.elements[(row * columns) + column]
        }
        set {
            assert(indexIsValid(row: row, column: column), "Index out of range")
            self.elements[(row * columns) + column] = newValue
        }
    }
    
    func indexIsValid(row: Int, column: Int) -> Bool {
        
        if row < 0 || column < 0 {
            return false
        }
        
        if row >= self.rows || column >= self.columns {
            return false
        }
        
        return true
        
    }
    
    var isSquare: Bool {
        return self.columns == self.rows
    }
    
    var isOrthogonal: Bool {
        if !isSquare { return false }
        
        for i in 0..<self.rows {
            
            for j in 0..<self.rows {
                
                var sum:Float = 0
                
                for k in 0..<self.columns {
                    
                    sum += self[i, k] * self[j, k]
                    
                }
                
                if i == j && abs(sum - 1) > 10 * Float.ulpOfOne {
                    return false
                }
                if i != j && abs(sum) > 10 * Float.ulpOfOne {
                    return false
                }
                    
            }
            
        }
        
        return true
        
    }
    
    //MARK:  Generic matrix math utility functions
    static func matrix4x4_rotation(radians: Float, axis: Vector3) -> Matrix {
        let unitAxis = axis.normalized()
        let ct = cos(radians)
        let st = sin(radians)
        let ci = 1 - ct
        let x = unitAxis.x, y = unitAxis.y, z = unitAxis.z
        return Matrix([[ct + x * x * ci, y * x * ci + z * st, z * x * ci - y * st, 0],
                       [x * y * ci - z * st,     ct + y * y * ci, z * y * ci + x * st, 0],
                       [x * z * ci + y * st, y * z * ci - x * st,     ct + z * z * ci, 0],
                       [0, 0, 0, 1]])
    }

    static func matrix4x4_translation(_ translationX: Float, _ translationY: Float, _ translationZ: Float) -> Matrix {
        return Matrix([[1, 0, 0, 0],
                       [0, 1, 0, 0],
                       [0, 0, 1, 0],
                       [translationX, translationY, translationZ, 1]])
    }

    static func matrix_perspective_right_hand(fovyRadians fovy: Float, aspectRatio: Float, nearZ: Float, farZ: Float) -> Matrix {
        let ys = 1 / tan(fovy * 0.5)
        let xs = ys / aspectRatio
        let zs = farZ / (nearZ - farZ)
        return Matrix([[xs,  0, 0,   0],
                        [0, ys, 0,   0],
                        [0,  0, zs, -1],
                        [0,  0, zs * nearZ, 0]])
    }
    
}
