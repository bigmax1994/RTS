//
//  FontLibrary.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 18.04.24.
//

import Foundation
import AppKit

struct FontLibrary {
    
    private static var fonts: [Font.Name : Font] = [:]
    
    static func Boot() {
        FontLibrary.addFont(Engine.defaultFont)
    }
    
    static func addFont(_ name: Font.Name, loadCharacters: [Character]? = nil) {
        self.fonts.updateValue(Font(name: name, loadSymbols: loadCharacters), forKey: .Arial)
    }
    
    public static func getFont(_ name: Font.Name) -> Font {
        if let font = FontLibrary.fonts[name] {
            return font
        }
        FontLibrary.addFont(name)
        return FontLibrary.fonts[name]!
    }
    
}

public class Font {
    
    public enum Name: String {
        case Arial = "Arial"
    }
    
    static let asciiCharacters:[Character] = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","0","1","2","3","4","5","6","7","8","9"]
    
    let parser: FontFileParser
    
    let name: Name
    let loadedSymbols: [Symbol]
    
    init(name: Name, loadSymbols: [Character]? = nil) {
        
        guard let fontFile: Data = NSDataAsset(name: name.rawValue)?.data else { fatalError("failed to find font") }
        let parser = FontFileParser(data: fontFile)
        
        let loadedSymbols:[Symbol] = (loadSymbols ?? Font.asciiCharacters).map({ char in
            
            return parser.getSymbol(char)
            
        })
        
        self.parser = parser
        self.name = name
        self.loadedSymbols = loadedSymbols
    }
    
}

class Symbol {
    
    let glyphs:[Glyph]
    
    init(glyphs: [Glyph]) {
        self.glyphs = glyphs
    }
    
}

class Glyph {
    
    var beziers:[BezierPath]
    let contourEnds:[Int]
    
    init(beziers: [BezierPath], conotourEnds: [Int]) {
        self.beziers = beziers
        self.contourEnds = conotourEnds
    }
    
    convenience init(points: [Vector2], conotourEnds: [Int]) {
        assert(points.count % 3 == 0, "incorrect amount of points")
        assert(points.count > 0, "no points")
        
        var beziers:[BezierPath] = []
        
        for i in 0..<points.count / 3 {
            beziers.append(BezierPath(p1: points[i * 3], p2: points[i * 3 + 1], cp: points[i * 3 + 2]))
        }
        
        self.init(beziers: beziers, conotourEnds: conotourEnds)
        
    }
    
}
