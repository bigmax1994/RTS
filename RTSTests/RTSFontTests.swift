//
//  RTSFontTests.swift
//  RTSTests
//
//  Created by Max Gasslitter Strobl on 04.05.24.
//

import XCTest
@testable import RTS

final class RTSFontTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        FontLibrary.Boot()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        FontLibrary.fonts = [:]
    }

    func testFontLibraryInit() throws {
        
        assert(FontLibrary.fonts.count == 1, "incorrect amount of fonts")
        
    }
    
    func testArialValues() throws {
        
        guard let fontFile: Data = NSDataAsset(name: Font.Name.Arial.rawValue)?.data else { fatalError("failed to find font") }
        let parser = FontFileParser(data: fontFile)
        
        
        
        print(parser.numTables)
        print(parser.numGlyphs)
        print(parser.unitsPerEM)
        print(parser.offsetFormat)
        print(parser.glyphRanges)
        print(parser.glyphFormat)
        print(parser.glyphIndecies)
    }
    
}
