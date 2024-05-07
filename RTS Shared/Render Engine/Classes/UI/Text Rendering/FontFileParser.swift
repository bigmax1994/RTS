//
//  FontFileParser.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 04.05.24.
//

import Foundation

class FontFileParser {

    enum Table: String {
        case Glyf = "glyf"
        case Location = "loca"
        case CMap = "cmap"
        case Head = "head"
        case MaxP = "maxp"
    }
    
    let data: Data
    
    init(data: Data) {
        self.data = data
    }
    
    func readUInt8(_ data: Data) -> Int {
        return Int(data.subdata(in: 0..<1).withUnsafeBytes({ $0.load(as: UInt8.self )}))
    }
    func readUInt16(_ data: Data) -> Int {
        let v = data.subdata(in: 0..<2).withUnsafeBytes({ $0.load(as: UInt16.self )})
        return Int(UInt16(bigEndian: v))
    }
    func readUInt32(_ data: Data) -> Int {
        let v = data.subdata(in: 0..<4).withUnsafeBytes({ $0.load(as: UInt32.self )})
        return Int(UInt32(bigEndian: v))
    }
    func readUInt64(_ data: Data) -> Int {
        let v = data.subdata(in: 0..<4).withUnsafeBytes({ $0.load(as: UInt64.self )})
        return Int(UInt64(bigEndian: v))
    }
    func readString(_ data: Data) -> String {
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    lazy var Tables: [Table : (Int, Int, Int)] = {
        var dic:[Table : (Int, Int, Int)] = [:]
        
        let generalInfo: Int = 12
        let tableInfoSize: Int = 16
        
        for i in 0..<self.numTables {
            
            let startIndex = generalInfo + i * tableInfoSize
            let endIndex = startIndex + tableInfoSize
            
            let tableData = self.data.subdata(in: startIndex..<endIndex)
            
            let tag = readString(tableData.subdata(in: 0..<4))
            let checkSum = readUInt32(tableData.subdata(in: 4..<8))
            let offset = readUInt32(tableData.subdata(in: 8..<12))
            let length = readUInt32(tableData.subdata(in: 12..<16))
            
            guard let table = Table(rawValue: tag) else {
                NSLog("Undefined Table Name \(tag)")
                continue
            }
                
            dic.updateValue((checkSum, offset, length), forKey: table)
            
        }
        
        return dic
        
    }()
    
    func getTableRange(_ table: Table) -> Range<Data.Index> {
        
        guard let tableInfo = self.Tables[table] else {
            NSLog("Tried to access table not in font file")
            return 0..<1
        }
        
        return tableInfo.1..<(tableInfo.1 + tableInfo.2)
        
    }
    
    lazy var numTables: Int = {
        return readUInt16(self.data.subdata(in: 4..<6))
    }()
    
    lazy var unitsPerEM: Int = {
        return readUInt16(self.data.subdata(in: self.getTableRange(.Head)).subdata(in: 18..<20))
    }()
    
    lazy var numGlyphs: Int = {
        return readUInt16(self.data.subdata(in: self.getTableRange(.MaxP)).subdata(in: 4..<6))
    }()
    
    lazy var offsetFormat: Int = {
        return readUInt16(self.data.subdata(in: self.getTableRange(.Head)).subdata(in: 50..<52))
    }()
    
    lazy var glyphRanges: [Range<Data.Index>] = {
        
        var arr: [Int] = []
        
        let locaTable = self.data.subdata(in: self.getTableRange(.Location))
        print(locaTable.subdata(in: 0..<2).base64EncodedString())
        let glyfTableStart = self.getTableRange(.Glyf).lowerBound
        
        let bytesPerEntry = (self.offsetFormat + 1) * 2
        
        for i in 0..<self.numGlyphs {
            
            let lowerBound = i * bytesPerEntry
            let upperBound = lowerBound + bytesPerEntry
            
            var offset: Int = 0
            if self.offsetFormat == 0 {
                offset = readUInt16(locaTable.subdata(in: lowerBound..<upperBound))
            }else if self.offsetFormat == 1 {
                offset = readUInt32(locaTable.subdata(in: lowerBound..<upperBound))
            }
            
            arr.append(glyfTableStart + offset)
            
        }
        
        var ranges: [Range<Data.Index>] = []
        for i in 0..<arr.count - 1 {
            ranges.append(arr[i]..<arr[i+1])
        }
        
        return ranges
        
    }()
    
    lazy var numCMapSubtables: Int = {
        return readUInt16(self.data.subdata(in: self.getTableRange(.CMap)).subdata(in: 2..<4))
    }()
    
    lazy var cmapSubtableOffset: Int = {
        
        var cmapSubtableOffset = 0
        var selectedUnicodeVersionID = -1
        
        let cMap = self.data.subdata(in: self.getTableRange(.CMap))

        for i in 0..<self.numCMapSubtables {
            let startIndex = i * 8 + 4
            
            let platformID = readUInt16(cMap.subdata(in: startIndex..<startIndex + 2))
            let platformSpecificID = readUInt16(cMap.subdata(in: startIndex + 2..<startIndex + 4))
            let offset = readUInt32(cMap.subdata(in: startIndex + 4..<startIndex + 8))

            // Unicode encoding
            if (platformID == 0) {
                // Use highest supported unicode version
                if (platformSpecificID == 0 ||
                    platformSpecificID == 1 ||
                    platformSpecificID == 3 ||
                    platformSpecificID == 4 &&
                    platformSpecificID > selectedUnicodeVersionID) {
                    
                    cmapSubtableOffset = offset
                    selectedUnicodeVersionID = platformSpecificID
                    
                }
            }
        }

        return cmapSubtableOffset
    }()
    
    lazy var glyphFormat: Int = {
        return readUInt16(self.data.subdata(in: self.getTableRange(.CMap)).subdata(in: cmapSubtableOffset..<cmapSubtableOffset + 2))
    }()
    
    lazy var glyphIndecies: [Character : Int] = {
        
        let cMap = self.data.subdata(in: self.getTableRange(.CMap))
        
        var dic: [Character : Int] = [:]
        var containsMissingChar = false
        
        if self.glyphFormat == 4 {
            
            let length = readUInt16(cMap.subdata(in: cmapSubtableOffset + 2..<cmapSubtableOffset + 4))
            let languageCode = readUInt16(cMap.subdata(in: cmapSubtableOffset + 4..<cmapSubtableOffset + 6))
            let segments = readUInt16(cMap.subdata(in: cmapSubtableOffset + 6..<cmapSubtableOffset + 8)) / 2
            
            var codes:[(Int, Int, Int, Int, Int)] = []
            
            var endIndex = cmapSubtableOffset + 8
            var startIndex = cmapSubtableOffset + 8 + segments * 2 + 2
            var idIndex = cmapSubtableOffset + 8 + segments * 2 * 2 + 2
            var offsetIndex = cmapSubtableOffset + 8 + segments * 2 * 3
            
            for _ in 0..<segments {
                
                let end = readUInt16(cMap.subdata(in: endIndex..<endIndex + 2))
                let start = readUInt16(cMap.subdata(in: startIndex..<startIndex + 2))
                let id = readUInt16(cMap.subdata(in: idIndex..<idIndex + 2))
                let offset = readUInt16(cMap.subdata(in: offsetIndex..<offsetIndex + 2))
                
                codes.append((end, start, id, offset, offsetIndex))
                
                endIndex += 2
                startIndex += 2
                idIndex += 2
                offsetIndex += 2
                
            }
            
            for code in codes {
                
                var currCode = code.1
                
                while currCode <= code.0 {
                    
                    var glyphIndex = 0
                    
                    if code.3 == 0 {
                        glyphIndex = (currCode + code.2) % 65536
                    }else{
                        let rangeOffsetLocation = code.4 + code.3
                        let glyphIndexArrayLocation = 2 * (currCode - code.1) + rangeOffsetLocation
                        
                        glyphIndex = readUInt16(cMap.subdata(in: glyphIndexArrayLocation..<glyphIndexArrayLocation + 2))
                        if glyphIndex != 0 {
                            glyphIndex = (glyphIndex + code.2) % 65536;
                        }
                    }
                    
                    guard let unicodeScalar = UnicodeScalar(currCode) else {
                        NSLog("unknown unicode \(glyphIndex)")
                        continue
                    }
                    dic.updateValue(glyphIndex, forKey: Character(unicodeScalar))
                    containsMissingChar = containsMissingChar || glyphIndex == 0
                    currCode += 1
                    
                }
                
            }
            
            
        }else if self.glyphFormat == 12 {
            
            
            
        }
        
        if !containsMissingChar {
            guard let unknownUnicodeScalar = UnicodeScalar(65535) else {
                NSLog("unknown unicode 65535")
                return dic
            }
            dic.updateValue(0, forKey: Character(unknownUnicodeScalar))
        }
        
        return dic
        
    }()
    
}
