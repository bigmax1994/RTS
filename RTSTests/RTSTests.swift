//
//  RTSTests.swift
//  RTSTests
//
//  Created by Magnus Saurbier on 19.03.24.
//

import XCTest
@testable import RTS
import simd

final class RTSTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        let heightmap = RTSHeightMap(n: 4)
    }
    
    func testMatrixMult() throws {
        
        let A = Matrix(elements: [1, 0, 0, 1], columns: 2, rows: 2)
        let B = Vector2(x: 2, y: 3)
        
        let C = A * B
        
        print(C)
        XCTAssert(C.toArray() == [2, 3], "incorrect output: \(C))")
        
    }
    
    func testRotationMastrix() throws {
        
        let v1 = Vector3(x: 1, y: 0, z: 0)
        let v2 = Vector3(x: 0, y: 1, z: 0)
        
        let m = Matrix.solveForRotation3x3(from: v1, to: v2)
        
        assert((m * v1 - v2).isZero(), "did not rotate correctly to \(m * v1) instead of \(v2)")
        
        let v3 = Vector3(x: -1, y: 0, z: 0)
        
        let m2 = Matrix.solveForRotation3x3(from: v3, to: v2)
        
        assert((m2 * v3 - v2).isZero(), "did not rotate correctly to \(m * v3) instead of \(v2)")
        
        assert(m.elements.enumerated().map({ $0.element - m2.elements[$0.offset] }).max() ?? 0 > 2 * Float.ulpOfOne, "same Matrix")
        
    }
    
    func test3x3VS4x4SolveForRotation() throws {
        
        let v1 = Vector3(x: 1, y: 0, z: 0)
        let v2 = Vector3(x: 0, y: 1, z: 0)
        let v3 = Vector3(x: 0, y: 1, z: 0)
        let v4 = Vector3(x: 0, y: 0, z: 1)
        
        let m11 = Matrix.solveForRotation4x4(from: v1, to: v2)
        let m12 = Matrix.solveForRotation4x4(from: v3, to: v4) * m11
        let m21 = Matrix.solveForRotation3x3(from: v1, to: v2)
        let m22 = Matrix.solveForRotation3x3(from: v3, to: v4) * m21
        
        let o11 = (m11 * Vector4(vec3: v1)).vec3
        let o12 = (m12 * Vector4(vec3: v1)).vec3
        
        let o21 = m21 * v1
        let o22 = m22 * v1
        
        assert((o11 - o21).isZero(), "not same result in first")
        assert((o12 - o22).isZero(), "not same result in second")
        
    }

    func testPerformanceOfMapSample() throws {
        
        let map = RTSMap_square(width: 200, height: 200)
        
        measure {
            let _ = RTSRenderer.sampleMap(from: map, with: 300)
        }
    }
    
    func testPointers() throws {
        
        let simd = simd_float3(1, 2, 3)
        withUnsafePointer(to: simd, { point in
            withUnsafePointer(to: point.pointee.x, { point in
                let mutable = UnsafeMutablePointer<Float>(mutating: point)
                mutable.pointee = 4
            })
        })
        
        assert(simd.x == 4, "did not set")
        
    }

}
