//
//  RTSClient.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 03.04.24.
//

import Foundation

class ConnectionScreen: World {
    
    let clientButtonRect: CGRect = CGRect(x: -1, y: -1, width: 1, height: 2)
    let serverButtonRect: CGRect = CGRect(x: 0, y: -1, width: 1, height: 2)
    
    init?() {
        
        let bgVerticies:[Vertex] = [Vertex(pos: simd_float3(-1, -1, 1), normal: simd_float3(0, 0, -1), material: Material(color: Color.green, opacity: 1, shininess: 0)),
                                    Vertex(pos: simd_float3(-1, 1, 1), normal: simd_float3(0, 0, -1), material: Material(color: Color.green, opacity: 1, shininess: 0)),
                                    Vertex(pos: simd_float3(1, -1, 1), normal: simd_float3(0, 0, -1), material: Material(color: Color.green, opacity: 1, shininess: 0)),
                                    Vertex(pos: simd_float3(-1, 1, 1), normal: simd_float3(0, 0, -1), material: Material(color: Color.green, opacity: 1, shininess: 0)),
                                    Vertex(pos: simd_float3(1, -1, 1), normal: simd_float3(0, 0, -1), material: Material(color: Color.green, opacity: 1, shininess: 0)),
                                    Vertex(pos: simd_float3(1, 1, 1), normal: simd_float3(0, 0, -1), material: Material(color: Color.green, opacity: 1, shininess: 0))]
        guard let background:Object = Object(verticies: bgVerticies, label: "connection bg") else { return nil }
        
        super.init(sunPos: Vector3(x: 0, y: 0, z: 1), sunColor: Color.white, ambientColor: Color.black, objects: [background])
        
        
    }
    
    func mouseDown(at pos: Vector2) {
        
        if pos.x >= Float(clientButtonRect.minX) && pos.x <= Float(clientButtonRect.maxX)
            && pos.y >= Float(clientButtonRect.minY) && pos.y <= Float(clientButtonRect.minY) {
            //client button clicked
            
            
            
        }
        
    }
    
}
