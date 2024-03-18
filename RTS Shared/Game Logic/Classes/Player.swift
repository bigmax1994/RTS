//
//  Player.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 05.03.24.
//

import Foundation
import ModelIO

class Player {
    
    var name: String
    var uuid: UUID
    
    var isFree: Bool = true
    
    private var position: Vector2 = Vector2()
    
    var mesh: MDLMesh?
    
    init(name: String) {
        self.name = name
        self.uuid = UUID()
        
        self.mesh = MDLMesh(vertexBuffer: <#T##MDLMeshBuffer#>, vertexCount: <#T##Int#>, descriptor: <#T##MDLVertexDescriptor#>, submeshes: <#T##[MDLSubmesh]#>)
        
    }
    
    func moveBy(_ vec: Vector2) {
        position = position + vec
    }
    
    func moveTo(_ pos: Vector2) {
        position = pos
    }
    
    func getPosition() -> Vector2 {
        return self.position
    }
    
}
