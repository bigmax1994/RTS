//
//  FontFileParser.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 04.05.24.
//

import Foundation

class FontFileParser {
    
    enum FontFileParserError: Error {
        case InvalidRanges
        case NilRange
        case InvalidLowerBound
        case InvalidUpperBound
    }

    enum Table: String {
        case Glyf = "glyf"
        case Location = "loca"
        case CharacterMap = "cmap"
        case Header = "head"
        case MaximumProfile = "maxp"
        case HorizontalHeader = "hhea"
        case HorizontalMetrics = "htmx"
    }
    
    let data: Data
    
    init(data: Data) {
        self.data = data
    }
    
    func readUInt8(_ data: Data?) -> Int? {
        if data == nil { NSLog("tried to read nil as UInt8"); return nil }
        if data!.count != 1 { NSLog("tried to read wrong data length as UInt8"); return nil }
        return Int(data!.withUnsafeBytes({ $0.load(as: UInt8.self )}))
    }
    func readInt8(_ data: Data?) -> Int? {
        if data == nil { NSLog("tried to read nil as Int8"); return nil }
        if data!.count != 1 { NSLog("tried to read wrong data length as Int8"); return nil }
        return Int(data!.withUnsafeBytes({ $0.load(as: Int8.self )}))
    }
    func readUInt16(_ data: Data?) -> Int? {
        if data == nil { NSLog("tried to read nil as UInt16"); return nil }
        if data!.count != 2 { NSLog("tried to read wrong data length as UInt16"); return nil }
        let v = data!.withUnsafeBytes({ $0.load(as: UInt16.self )})
        return Int(UInt16(bigEndian: v))
    }
    func readInt16(_ data: Data?) -> Int? {
        if data == nil { NSLog("tried to read nil as Int16"); return nil }
        if data!.count != 2 { NSLog("tried to read wrong data length as Int16"); return nil }
        let v = data!.withUnsafeBytes({ $0.load(as: Int16.self )})
        return Int(Int16(bigEndian: v))
    }
    func readUInt32(_ data: Data?) -> Int? {
        if data == nil { NSLog("tried to read nil as UInt32"); return nil }
        if data!.count != 4 { NSLog("tried to read wrong data length as UInt32"); return nil }
        let v = data!.withUnsafeBytes({ $0.load(as: UInt32.self )})
        return Int(UInt32(bigEndian: v))
    }
    func readUInt64(_ data: Data?) -> Int? {
        if data == nil { NSLog("tried to read nil as UInt64"); return nil }
        if data!.count != 8 { NSLog("tried to read wrong data length as UInt64"); return nil }
        let v = data!.withUnsafeBytes({ $0.load(as: UInt64.self )})
        return Int(UInt64(bigEndian: v))
    }
    func readString(_ data: Data?) -> String? {
        if data == nil { NSLog("tried to read nil as String"); return nil }
        if data!.count < 1 { NSLog("tried to read wrong data length as String"); return nil }
        return String(data: data!, encoding: .utf8)
    }
    
    private func getDataSlice(in ranges: (Int, Int)?...) -> Data? {
        do {
            let ranges:[Range<Data.Index>] = try ranges.map { bounds in
                if bounds == nil {
                    throw FontFileParserError.NilRange
                }
                if bounds!.0 < 0 {
                    throw FontFileParserError.InvalidLowerBound
                }
                if bounds!.1 <= bounds!.0 {
                    throw FontFileParserError.InvalidUpperBound
                }
                return bounds!.0..<bounds!.1
            }
            
            let definiteRange:Range<Data.Index> = try ranges.reduce(into: 0..<self.data.count) { partialResult, range in
                let newLowerBound = partialResult.lowerBound + range.lowerBound
                let newUpperBound = partialResult.lowerBound + range.upperBound
                if newLowerBound >= newUpperBound || newUpperBound > partialResult.upperBound {
                    throw FontFileParserError.InvalidRanges
                }
                partialResult = newLowerBound..<newUpperBound
            }
            
            return self.data.subdata(in: definiteRange)
        } catch FontFileParserError.NilRange {
            NSLog("Submitted nil Range")
        } catch FontFileParserError.InvalidLowerBound {
            NSLog("Can't create Range: lower bound < 0")
        } catch FontFileParserError.InvalidUpperBound {
            NSLog("Can't create Range: upper bound < lower bound")
        } catch FontFileParserError.InvalidRanges {
            NSLog("Invalid Ranges submitted")
        } catch let error {
            NSLog("Unknown error reducing ranges: \(error)")
        }
        
        return nil
        
    }
    
    lazy var Tables: [Table : (Int, Int, Int)] = {
        var dic:[Table : (Int, Int, Int)] = [:]
        
        guard let numTables = self.numTables else { return dic }
        
        let generalInfo: Int = 12
        let tableInfoSize: Int = 16
        
        for i in 0..<numTables {
            
            let startIndex = generalInfo + i * tableInfoSize
            let endIndex = startIndex + tableInfoSize
            
            guard let tag = readString(self.getDataSlice(in: (startIndex, endIndex), (0, 4))) else { continue }
            guard let checkSum = readUInt32(self.getDataSlice(in: (startIndex, endIndex), (4, 8))) else { continue }
            guard let offset = readUInt32(self.getDataSlice(in: (startIndex, endIndex), (8, 12))) else { continue }
            guard let length = readUInt32(self.getDataSlice(in: (startIndex, endIndex), (12, 16))) else { continue }
            
            guard let table = Table(rawValue: tag) else {
                NSLog("Undefined Table Name \(tag)")
                continue
            }
                
            dic.updateValue((checkSum, offset, length), forKey: table)
            
        }
        
        return dic
        
    }()
    
    func getTableRange(_ table: Table) -> (Int, Int)? {
        
        guard let tableInfo = self.Tables[table] else {
            NSLog("Tried to access table not in font file")
            return nil
        }
        
        return (tableInfo.1, (tableInfo.1 + tableInfo.2))
        
    }
    
    lazy var numTables: Int? = {
        return readUInt16(self.getDataSlice(in: (4,6)))
    }()
    
    lazy var unitsPerEM: Int? = {
        return readUInt16(self.getDataSlice(in: self.getTableRange(.Header), (18, 20)))
    }()
    
    lazy var numGlyphs: Int? = {
        return readUInt16(self.getDataSlice(in: self.getTableRange(.MaximumProfile), (4, 6)))
    }()
    
    lazy var offsetFormat: Int? = {
        return readUInt16(self.getDataSlice(in: self.getTableRange(.Header), (50, 52)))
    }()
    
    lazy var glyphRanges: [(Int, Int)] = {
        
        var arr: [Int] = []
        
        guard let offsetFormat = self.offsetFormat else { return [] }
        guard let numGlyphs = self.numGlyphs else { return [] }
        guard let locaTable = self.getDataSlice(in: self.getTableRange(.Location)) else { return [] }
        guard let glyfTableStart = self.getTableRange(.Glyf)?.0 else { return [] }
        
        let bytesPerEntry = (offsetFormat + 1) * 2
        
        for i in 0..<numGlyphs+1 {
            
            let lowerBound = i * bytesPerEntry
            let upperBound = lowerBound + bytesPerEntry
            
            let offset: Int = self.offsetFormat == 0 ?
                (readUInt16(self.getDataSlice(in: self.getTableRange(.Location), (lowerBound, upperBound))) ?? 0) * 2 :
                self.offsetFormat == 1 ?
                    readUInt32(self.getDataSlice(in: self.getTableRange(.Location), (lowerBound, upperBound))) ?? 0 :
                    0
            
            arr.append(glyfTableStart + offset)
            
        }
        
        var ranges: [(Int, Int)] = []
        for i in 0..<arr.count - 1 {
            ranges.append((arr[i], arr[i+1]))
        }
        
        return ranges
        
    }()
    
    lazy var numCharacterMapSubtables: Int? = {
        return readUInt16(self.getDataSlice(in: self.getTableRange(.CharacterMap), (2, 4)))
    }()
    
    lazy var CharacterMapSubtableOffset: Int? = {
        
        var CharacterMapSubtableOffset = 0
        var selectedUnicodeVersionID = -1
        
        guard let numCharacterMapSubtables = self.numCharacterMapSubtables else { return nil }

        for i in 0..<numCharacterMapSubtables {
            let startIndex = i * 8 + 4
            
            guard let platformID = readUInt16(self.getDataSlice(in: self.getTableRange(.CharacterMap), (startIndex, startIndex + 2))) else { continue }
            guard let platformSpecificID = readUInt16(self.getDataSlice(in: self.getTableRange(.CharacterMap), (startIndex + 2, startIndex + 4))) else { continue }
            guard let offset = readUInt32(self.getDataSlice(in: self.getTableRange(.CharacterMap), (startIndex + 4, startIndex + 8))) else { continue }

            // Unicode encoding
            if (platformID == 0) {
                // Use highest supported unicode version
                if (platformSpecificID == 0 ||
                    platformSpecificID == 1 ||
                    platformSpecificID == 3 ||
                    platformSpecificID == 4 &&
                    platformSpecificID > selectedUnicodeVersionID) {
                    
                    CharacterMapSubtableOffset = offset
                    selectedUnicodeVersionID = platformSpecificID
                    
                }
            }
        }

        return CharacterMapSubtableOffset
    }()
    
    lazy var glyphFormat: Int? = {
        guard let CharacterMapSubtableOffset = self.CharacterMapSubtableOffset else { return nil }
        return readUInt16(self.getDataSlice(in: self.getTableRange(.CharacterMap), (CharacterMapSubtableOffset, CharacterMapSubtableOffset + 2)))
    }()
    
    private enum GlyphWrapper {
        case index(Int)
        case symbol(Symbol)
    }
    
    private lazy var glyphs: [Character : GlyphWrapper] = {
        
        var dic: [Character : GlyphWrapper] = [:]
        
        guard let CharacterMapSubtableOffset = self.CharacterMapSubtableOffset else { return dic }
        var containsMissingChar = false
        
        glyphFormatFour: if self.glyphFormat == 4 {
            
            guard let length = readUInt16(self.getDataSlice(in: self.getTableRange(.CharacterMap), (CharacterMapSubtableOffset + 2, CharacterMapSubtableOffset + 4))) else { break glyphFormatFour }
            guard let languageCode = readUInt16(self.getDataSlice(in: self.getTableRange(.CharacterMap), (CharacterMapSubtableOffset + 4, CharacterMapSubtableOffset + 6))) else { break glyphFormatFour }
            guard let segments2 = readUInt16(self.getDataSlice(in: self.getTableRange(.CharacterMap), (CharacterMapSubtableOffset + 6, CharacterMapSubtableOffset + 8))) else { break glyphFormatFour }
            
            let segments = segments2 / 2
            
            var codes:[(end: Int, start: Int, id: Int, offset: Int, offsetIndex: Int)] = []
            
            var endIndex = CharacterMapSubtableOffset + 14
            var startIndex = endIndex + segments2 + 2
            var idIndex = startIndex + segments2
            var offsetIndex = idIndex + segments2
            
            for _ in 0..<segments {
                
                guard let end = readUInt16(self.getDataSlice(in: self.getTableRange(.CharacterMap), (endIndex, endIndex + 2))) else { continue }
                guard let start = readUInt16(self.getDataSlice(in: self.getTableRange(.CharacterMap), (startIndex, startIndex + 2))) else { continue }
                guard let id = readUInt16(self.getDataSlice(in: self.getTableRange(.CharacterMap), (idIndex, idIndex + 2))) else { continue }
                guard let offset = readUInt16(self.getDataSlice(in: self.getTableRange(.CharacterMap), (offsetIndex, offsetIndex + 2))) else { continue }
                
                codes.append((end, start, id, offset, offsetIndex))
                
                endIndex += 2
                startIndex += 2
                idIndex += 2
                offsetIndex += 2
                
            }
            
            for code in codes {
                
                var currCode = code.start
                if currCode == 65535 { break } //no idea why
                
                while currCode <= code.end {
                    
                    var glyphIndex = 0
                    
                    if code.offset == 0 {
                        glyphIndex = (currCode + code.id) % 65536
                    }else{
                        let rangeOffsetLocation = code.offsetIndex + code.offset
                        let glyphIndexArrayLocation = 2 * (currCode - code.start) + rangeOffsetLocation
                        
                        guard let newIndex = readUInt16(self.getDataSlice(in: self.getTableRange(.CharacterMap), (glyphIndexArrayLocation, glyphIndexArrayLocation + 2))) else {
                            NSLog("couldn't look up glyphIndex in array")
                            currCode += 1
                            continue
                        }
                        glyphIndex = newIndex
                        if glyphIndex != 0 {
                            glyphIndex = (glyphIndex + code.id) % 65536;
                        }
                    }
                    
                    guard let unicodeScalar = UnicodeScalar(currCode) else {
                        NSLog("unknown unicode \(glyphIndex)")
                        currCode += 1
                        continue
                    }
                    dic.updateValue(.index(glyphIndex), forKey: Character(unicodeScalar))
                    containsMissingChar = containsMissingChar || glyphIndex == 0
                    currCode += 1
                    
                }
                
            }
            
            
        }else if self.glyphFormat == 12 {
            
            fatalError("not implemented")
            
        }
        
        if !containsMissingChar {
            guard let unknownUnicodeScalar = UnicodeScalar(65535) else {
                NSLog("unknown unicode 65535")
                return dic
            }
            dic.updateValue(.index(0), forKey: Character(unknownUnicodeScalar))
        }
        
        let maxIndex = dic.reduce(0) { partialResult, index in
            switch index.value {
            case .index(let i): return max(partialResult, i)
            default: return partialResult
            }
        }
        
        if maxIndex >= self.numGlyphs ?? 0 {
            NSLog("invalid glyph indecies")
            
        }
        
        return dic
        
    }()
    
    public func getSymbol(_ char: Character) -> Symbol {
        if let g = self.glyphs[char] {
            switch g {
            case .index(let i):
                guard let symbol = self.getGlyph(i) else { return getDefaultSymbol() }
                self.glyphs.updateValue(.symbol(symbol), forKey: char)
                return symbol
            case .symbol(let symbol): return symbol
            }
        }
        return getDefaultSymbol()
    }
    
    private func getDefaultSymbol() -> Symbol {
        return self.getGlyph(0) ?? Symbol(glyphs: [])
    }
    
    private func getGlyph(_ index: Int) -> Symbol? {
        if index < 0 || index >= self.glyphRanges.count {
            NSLog("tried to acces invalid glyph index")
            return nil
        }
        
        let range = self.glyphRanges[index]
        
        guard let contours = readInt16(self.getDataSlice(in: range, (0, 2))) else { return nil }
        
        if contours >= 0 {
            guard let glyph = self.readSimpleGlyph(in: range) else { return nil }
            return Symbol(glyphs: [glyph])
        } else {
            return self.readCompoundGlyph(in: range)
        }
        
    }
    // Flag masks
    static let FlagMasks = (onCurve: 0, isSingleByteX: 1, isSingleByteY: 2, repeat: 3, instructionX: 4, instructionY: 5)
    
    private func readSimpleGlyph(in range: (Int, Int)) -> Glyph? {
        
        guard let pointsPerEmInt = self.unitsPerEM else { return nil }
        let pointsPerEm = Float(pointsPerEmInt)
        
        guard let contours = readInt16(self.getDataSlice(in: range, (0,2))) else { return nil }
        
        guard let minX = readInt16(self.getDataSlice(in: range, (2,4))) else { return nil }
        guard let minY = readInt16(self.getDataSlice(in: range, (4,6))) else { return nil }
        guard let maxX = readInt16(self.getDataSlice(in: range, (6,8))) else { return nil }
        guard let maxY = readInt16(self.getDataSlice(in: range, (8,10))) else { return nil }
        
        var endPoints:[Int] = []
        var totalPoints = 0
        for i in 0..<contours {
            guard let point = readInt16(self.getDataSlice(in: range, (10 + i * 2, 10 + i * 2 + 2))) else { return nil }
            totalPoints = max(totalPoints, point + 1)
            endPoints.append(point)
        }
        
        let indexAfterEndPoints = 10 + contours * 2
        guard let instructionLength = readInt16(self.getDataSlice(in: range, (indexAfterEndPoints, indexAfterEndPoints + 2))) else { return nil }
        
        var currentIndexAfterInstructions = indexAfterEndPoints + 2 + instructionLength
        
        var flags:[Int] = []
        var i = 0
        while i < totalPoints {
            guard let flag = readUInt8(self.getDataSlice(in: range, (currentIndexAfterInstructions, currentIndexAfterInstructions + 1))) else { return nil }
            currentIndexAfterInstructions += 1
            var amountRepeats = 1
            if FontFileParser.checkFlagBit(flag, at: FontFileParser.FlagMasks.repeat) {
                guard let repeats = readUInt8(self.getDataSlice(in: range, (currentIndexAfterInstructions, currentIndexAfterInstructions + 1))) else { return nil }
                currentIndexAfterInstructions += 1
                amountRepeats = repeats
            }
            
            flags.append(contentsOf: Array(repeating: flag, count: amountRepeats))
            i += amountRepeats
        }
        
        var xPoints:[Int] = []
        var lastX = 0
        for i in 0..<totalPoints {
            let flag = flags[i]
            
            if FontFileParser.checkFlagBit(flag, at: FontFileParser.FlagMasks.isSingleByteX) {
                guard let offset = readUInt8(self.getDataSlice(in: range, (currentIndexAfterInstructions, currentIndexAfterInstructions + 1))) else { return nil }
                currentIndexAfterInstructions += 1
                let positive = FontFileParser.checkFlagBit(flag, at: FontFileParser.FlagMasks.instructionX)
                lastX += positive ? offset : -offset
            }else if !FontFileParser.checkFlagBit(flag, at: FontFileParser.FlagMasks.instructionX) {
                guard let offset = readInt16(self.getDataSlice(in: range, (currentIndexAfterInstructions, currentIndexAfterInstructions + 2))) else { return nil }
                currentIndexAfterInstructions += 2
                lastX += offset
            }
            
            xPoints.append(lastX)
            
        }
        
        var yPoints:[Int] = []
        var lastY = 0
        for i in 0..<totalPoints {
            let flag = flags[i]
            
            if FontFileParser.checkFlagBit(flag, at: FontFileParser.FlagMasks.isSingleByteY) {
                guard let offset = readUInt8(self.getDataSlice(in: range, (currentIndexAfterInstructions, currentIndexAfterInstructions + 1))) else { return nil }
                currentIndexAfterInstructions += 1
                let positive = FontFileParser.checkFlagBit(flag, at: FontFileParser.FlagMasks.instructionY)
                lastX += positive ? offset : -offset
            }else if !FontFileParser.checkFlagBit(flag, at: FontFileParser.FlagMasks.instructionY) {
                guard let offset = readInt16(self.getDataSlice(in: range, (currentIndexAfterInstructions, currentIndexAfterInstructions + 2))) else { return nil }
                currentIndexAfterInstructions += 2
                lastY += offset
            }
            
            yPoints.append(lastY)
            
        }
        
        var lastPoint:Vector2? = Vector2(x: Float(xPoints[0]) / pointsPerEm, y: Float(yPoints[0]) / pointsPerEm)
        var lastFlag:Int? = flags[0]
        var contourStart = 0
        
        //array containing 3 * n points in pattern: point1, controll point, point2
        var points: [Vector2] = []
        
        for i in 1..<totalPoints {
            
            if let lp = lastPoint {
                points.append(lp)
            }
            
            let x = Float(xPoints[i])
            let y = Float(yPoints[i])
            let p = Vector2(x: x / pointsPerEm, y: y / pointsPerEm)
            let flag = flags[i]
            
            //if both points are on or off curve insert a impled mid point
            if let lp = lastPoint, let lf = lastFlag, FontFileParser.checkFlagBit(flag, at: FontFileParser.FlagMasks.onCurve) == FontFileParser.checkFlagBit(lf, at: FontFileParser.FlagMasks.onCurve) {
                
                let midPoint = lp + 0.5 * p
                points.append(midPoint)
                
                points.append(p)
                
            }
            
            lastPoint = p
            lastFlag = flag
            
            //close contour
            if endPoints.contains(i) {
                
                points.append(p)
                
                let x = Float(xPoints[contourStart])
                let y = Float(yPoints[contourStart])
                let p = Vector2(x: x / pointsPerEm, y: y / pointsPerEm)
                let flag = flags[contourStart]
                
                //if both points are on or off curve insert a impled mid point
                if let lp = lastPoint, let lf = lastFlag, FontFileParser.checkFlagBit(flag, at: FontFileParser.FlagMasks.onCurve) == FontFileParser.checkFlagBit(lf, at: FontFileParser.FlagMasks.onCurve) {
                    
                    let midPoint = lp + 0.5 * p
                    points.append(midPoint)
                    
                }
                
                points.append(p)
                contourStart = i + 1
                
                lastPoint = nil
                lastFlag = nil
                
            }
            
        }
        
        return Glyph(points: points, conotourEnds: endPoints)
        
    }
    
    // Compound Flag masks
    static let CompoundFlagMasks = (argsAreWords: 0, argsAreXY: 1, roundXY: 2, hasScale: 3, moreComponents: 5, differentXYScale: 6, hasTrafoMatrix: 7, hasInstructions: 8, useMetrics: 9, overlaps: 10)
    
    private func readCompoundGlyph(in range: (Int, Int)) -> Symbol? {
        
        guard let unitsPerEMInt = self.unitsPerEM else { return nil }
        let unitsPerEM = Float(unitsPerEMInt)
        
        guard let minX = readInt16(self.getDataSlice(in: range, (2,4))) else { return nil }
        guard let minY = readInt16(self.getDataSlice(in: range, (4,6))) else { return nil }
        guard let maxX = readInt16(self.getDataSlice(in: range, (6,8))) else { return nil }
        guard let maxY = readInt16(self.getDataSlice(in: range, (8,10))) else { return nil }
        
        var allGlyphs:[Glyph] = []
        
        var pointer = range.0 + 10
        while true {
            
            guard let flag = self.readUInt16(self.getDataSlice(in: range, (pointer, pointer + 2))) else { return nil }
            pointer += 2
            guard let glyphIndex = self.readUInt16(self.getDataSlice(in: range, (pointer, pointer + 2))) else { return nil }
            pointer += 2
            
            if glyphIndex < 0 || glyphIndex >= self.glyphRanges.count { return nil }
            let glyphRange = self.glyphRanges[glyphIndex]
            
            let decodedFlag = (argsAreWords: FontFileParser.checkFlagBit(flag, at: FontFileParser.CompoundFlagMasks.argsAreWords),
                               argsAreXY: FontFileParser.checkFlagBit(flag, at: FontFileParser.CompoundFlagMasks.argsAreXY),
                               roundXY: FontFileParser.checkFlagBit(flag, at: FontFileParser.CompoundFlagMasks.roundXY),
                               hasScale: FontFileParser.checkFlagBit(flag, at: FontFileParser.CompoundFlagMasks.hasScale),
                               moreComponents: FontFileParser.checkFlagBit(flag, at: FontFileParser.CompoundFlagMasks.moreComponents),
                               differentXYScale: FontFileParser.checkFlagBit(flag, at: FontFileParser.CompoundFlagMasks.differentXYScale),
                               hasTrafoMatrix: FontFileParser.checkFlagBit(flag, at: FontFileParser.CompoundFlagMasks.hasTrafoMatrix),
                               hasInstructions: FontFileParser.checkFlagBit(flag, at: FontFileParser.CompoundFlagMasks.hasInstructions),
                               useMetrics: FontFileParser.checkFlagBit(flag, at: FontFileParser.CompoundFlagMasks.useMetrics),
                               overlaps: FontFileParser.checkFlagBit(flag, at: FontFileParser.CompoundFlagMasks.overlaps))
            
            guard let arg1 = decodedFlag.argsAreWords ? self.readInt16(self.getDataSlice(in: range, (pointer, pointer + 2))) : self.readInt8(self.getDataSlice(in: range, (pointer, pointer + 1))) else { return nil }
            pointer += decodedFlag.argsAreWords ? 2 : 1
            guard let arg2 = decodedFlag.argsAreWords ? self.readInt16(self.getDataSlice(in: range, (pointer, pointer + 2))) : self.readInt8(self.getDataSlice(in: range, (pointer, pointer + 1))) else { return nil }
            pointer += decodedFlag.argsAreWords ? 2 : 1
            
            var offset: Vector2 = Vector2()
            if decodedFlag.argsAreXY {
                offset.x = Float(arg1) / unitsPerEM
                offset.y = Float(arg2) / unitsPerEM
            }else{
                //MARK: MISSING IMPLEMENTATION
            }
            
            var trafoMatrix = Matrix.Identity(2)
            
            if decodedFlag.hasScale {
                guard let scale = self.readInt16(self.getDataSlice(in: range, (pointer, pointer + 2))) else { return nil }
                pointer += 2
                let fscale = FontFileParser.ShortToFloat(scale)
                trafoMatrix[0, 0] = fscale
                trafoMatrix[1, 1] = fscale
            }else if decodedFlag.differentXYScale {
                guard let scaleX = self.readInt16(self.getDataSlice(in: range, (pointer, pointer + 2))) else { return nil }
                pointer += 2
                guard let scaleY = self.readInt16(self.getDataSlice(in: range, (pointer, pointer + 2))) else { return nil }
                pointer += 2
                let fscaleX = FontFileParser.ShortToFloat(scaleX)
                let fscaleY = FontFileParser.ShortToFloat(scaleY)
                trafoMatrix[0, 0] = fscaleX
                trafoMatrix[1, 1] = fscaleY
            }else if decodedFlag.hasTrafoMatrix {
                guard let scaleXX = self.readInt16(self.getDataSlice(in: range, (pointer, pointer + 2))) else { return nil }
                pointer += 2
                guard let scaleXY = self.readInt16(self.getDataSlice(in: range, (pointer, pointer + 2))) else { return nil }
                pointer += 2
                guard let scaleYX = self.readInt16(self.getDataSlice(in: range, (pointer, pointer + 2))) else { return nil }
                pointer += 2
                guard let scaleYY = self.readInt16(self.getDataSlice(in: range, (pointer, pointer + 2))) else { return nil }
                pointer += 2
                let fscaleXX = FontFileParser.ShortToFloat(scaleXX)
                let fscaleXY = FontFileParser.ShortToFloat(scaleXY)
                let fscaleYX = FontFileParser.ShortToFloat(scaleYX)
                let fscaleYY = FontFileParser.ShortToFloat(scaleYY)
                trafoMatrix[0, 0] = fscaleXX
                trafoMatrix[0, 1] = fscaleXY
                trafoMatrix[1, 0] = fscaleYX
                trafoMatrix[1, 1] = fscaleYY
            }
            
            guard let glyph = self.readSimpleGlyph(in: glyphRange) else { return nil }
            for i in 0..<glyph.beziers.count {
                
                let p1 = trafoMatrix * glyph.beziers[i].p1 + offset
                let p2 = trafoMatrix * glyph.beziers[i].p2 + offset
                let cp = trafoMatrix * glyph.beziers[i].cp + offset
                
                glyph.beziers[i] = BezierPath(p1: p1, p2: p2, cp: cp)
                
            }
            
            if !decodedFlag.moreComponents { break }
            
        }
        
        return Symbol(glyphs: allGlyphs)
        
    }
    
    private static func checkFlagBit(_ flag: Int, at bitIndex: Int) -> Bool {
        return (flag >> bitIndex) & 1 == 1
    }
    
    private static func ShortToFloat(_ short: Int) -> Float {
        let sign:Float = (short & 65536) == 65536 ? -1 : 1
        return sign * Float(short & 65535) / 32768
    }
    
}
