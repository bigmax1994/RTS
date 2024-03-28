//
//  MatrixCalc.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 18.03.24.
//

import Foundation
import Accelerate

extension Matrix {
    
    static func slowDotAdd(alpha: Float = 1, A: Matrix, transposeA: Bool = false, B: Matrix, transposeB: Bool = false, beta: Float = 1, C: Matrix? = nil) -> Matrix {
        
        let m = transposeA ? A.columns : A.rows
        let n = transposeB ? B.rows : B.columns
        let k = transposeA ? A.rows : A.columns
        let k1 = transposeB ? B.columns : B.rows
        
        assert(k == k1, "incompatible matricies")
        
        var output = C
        if output == nil {
            output = Matrix(columns: n, rows: m)
        }
        
        for i in 0..<m {
            for j in 0..<n {
                output![i, j] *= beta
                for k in 0..<k {
                    output![i, j] += A[i, k] * B[k, j]
                }
                output![i, j] *= alpha
            }
        }
        
        return output!
        
    }
    
    static func fastDotAdd(alpha: Float = 1, A: Matrix, transposeA: Bool = false, B: Matrix, transposeB: Bool = false, beta: Float = 1, C: Matrix? = nil) -> Matrix {
        
        let m = transposeA ? A.columns : A.rows
        let n = transposeB ? B.rows : B.columns
        let k = transposeA ? A.rows : A.columns
        let k1 = transposeB ? B.columns : B.rows
        
        assert(k == k1, "incompatible matricies")
        
        var output = C
        if output == nil {
            output = Matrix(columns: n, rows: m)
        }
        
        cblas_sgemm(CblasRowMajor,
                    transposeA ? CblasTrans : CblasNoTrans,
                    transposeB ? CblasTrans : CblasNoTrans,
                    Int32(m),
                    Int32(n),
                    Int32(k),
                    alpha,
                    A.elements,
                    Int32(A.columns),
                    B.elements,
                    Int32(B.columns),
                    beta,
                    &output!.elements,
                    Int32(output!.columns))
        
        return output!
        
    }
    
    static func * (rhs: Matrix, lhs: Matrix) -> Matrix {
        
        return slowDotAdd(A: rhs, B: lhs)
        
    }
    
    static func * (rhs: Float, lhs: Matrix) -> Matrix {
        
        return Matrix(elements: lhs.elements.map({ rhs * $0 }), columns: lhs.columns, rows: lhs.rows)
        
    }
    
}
