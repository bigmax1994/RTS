//
//  MatrixCalc.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 18.03.24.
//

import Foundation
import Accelerate

extension Matrix {
    
    static func fastDotAdd(alpha: Float = 1, A: Matrix, transposeSelf: Bool = false, B: Matrix, transposeDot: Bool = false, beta: Float = 1, C: Matrix? = nil) -> Matrix {
        
        var output = C
        if output == nil {
            output = Matrix(columns: A.rows, rows: B.columns)
        }
        
        cblas_sgemm(CblasRowMajor,
                    transposeSelf ? CblasTrans : CblasNoTrans,
                    transposeDot ? CblasTrans : CblasNoTrans,
                    Int32(A.rows),
                    Int32(B.columns),
                    Int32(A.columns),
                    alpha,
                    A.elements,
                    Int32(A.rows),
                    B.elements,
                    Int32(B.rows),
                    beta,
                    &output!.elements,
                    Int32(output!.rows))
        
        return output!
        
    }
    
}
