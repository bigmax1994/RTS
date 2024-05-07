//
//  FontLibrary.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 18.04.24.
//

import Foundation
import AppKit

struct FontLibrary {
    
    static var fonts: [Font.Name : Font] = [:]
    
    static func Boot() {
        self.fonts.updateValue(Font(name: .Arial), forKey: .Arial)
    }
    
}

public class Font {
    
    public enum Name: String {
        case Arial = "Arial"
    }
    
    static let asciiCharacters:[UInt8] = {
        let ascii:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
        var chars: [UInt8] = []
        for c in ascii.utf8 {
            chars.append(c)
        }
        return chars
    }()
    
    let name: Name
    let loadedSymbols: [Symbol]
    
    init(name: Name, loadedSymbols: [Symbol]? = nil) {
        
        guard let fontFile: Data = NSDataAsset(name: name.rawValue)?.data else { fatalError("failed to find font") }
        let parser = FontFileParser(data: fontFile)
        
        let loadedSymbols:[Symbol] = loadedSymbols ?? []/*Font.asciiCharacters.map({ uint8 in
            
            let points:[Vector2] = []
            
            return Symbol(points: points)
            
        })*/
        
        self.name = name
        self.loadedSymbols = loadedSymbols
    }
    
}

class Symbol {
    
    let beziers:[BezierPath]
    
    init(beziers: [BezierPath]) {
        self.beziers = beziers
    }
    
    convenience init(points: [Vector2]) {
        assert(points.count % 3 != 0, "incorrect amount of points")
        assert(points.count == 0, "no points")
        
        var beziers:[BezierPath] = []
        
        for i in 0..<points.count / 3 {
            beziers.append(BezierPath(p1: points[i * 3], p2: points[i * 3 + 1], cp: points[i * 3 + 2]))
        }
        
        self.init(beziers: beziers)
        
    }
    
}
