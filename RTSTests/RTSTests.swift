//
//  RTSTests.swift
//  RTSTests
//
//  Created by Magnus Saurbier on 19.03.24.
//

import XCTest
@testable import RTS

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
        
        let A = Matrix(elements: [1, 0, 1, 0], columns: 2, rows: 2)
        let B = Matrix(elements: [2, 3], columns: 1, rows: 2)
        
        let C = Matrix.fastDotAdd(A: A, B: B)
        
        print(C)
        XCTAssert(C.elements == [2, 2], "incorrect output: \(C.elements))")
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
