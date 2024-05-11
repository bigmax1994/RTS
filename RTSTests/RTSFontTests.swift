//
//  RTSFontTests.swift
//  RTSTests
//
//  Created by Max Gasslitter Strobl on 04.05.24.
//

import XCTest
@testable import RTS

final class RTSFontTests: XCTestCase {

    let testBundle = Bundle(for: RTSFontTests.self)
    
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
    
    func testAhemValues() throws {
        
        guard let fontFile: Data = NSDataAsset(name: "Ahem", bundle: self.testBundle)?.data else { fatalError("failed to find font") }
        let parser = FontFileParser(data: fontFile)
        
        assert(parser.numTables == 11)
        assert(parser.numGlyphs == 245)
        assert(parser.unitsPerEM == 1000)
        assert(parser.offsetFormat == 0)
        assert(parser.glyphFormat == 4)
        assert(parser.glyphRanges.count == 245)
        
    }
    
    func testReadSimpleGlyph() throws {
        
        guard let fontFile: Data = NSDataAsset(name: "Arial")?.data else { fatalError("failed to find font") }
        let parser:FontFileParser = FontFileParser(data: fontFile)
        
        let symbol:Symbol? = parser.getSymbol("A")
        assert(symbol != nil)
        print(symbol!.glyphs[0].beziers)
        
    }
    
    func testReadCompoundGlyph() throws {
        
        guard let fontFile: Data = NSDataAsset(name: "Arial")?.data else { fatalError("failed to find font") }
        let parser:FontFileParser = FontFileParser(data: fontFile)
        
        print(parser.numGlyphs)
        print(parser.glyphRanges.count)
        print(parser.getTableRange(.Location))
        print(parser.offsetFormat)
        
        let symbol:Symbol? = parser.getSymbol("i")
        assert(symbol != nil)
        print(symbol!.glyphs[0].beziers)
        
    }
    
}
