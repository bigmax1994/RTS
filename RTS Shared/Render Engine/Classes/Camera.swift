//
//  Camera.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 19.03.24.
//

import Foundation
import simd

class Camera {
    
    static let defaultPos: Vector3 = Vector3(x: 0, y: 0, z: 1)
    static let defaultDir: Vector3 = Vector3(x: 0, y: 0, z: -1)
    static let defaultUp: Vector3 = Vector3(x: 0, y: 1, z: 0)
    
    var position: Vector3
    var direction: Vector3
    var up: Vector3
    
    var trafo:CameraTransformation?
    
    convenience init() {
        self.init(pos: Camera.defaultPos, dir:Camera.defaultDir, up: Camera.defaultUp)
    }
    
    init(pos: Vector3, dir: Vector3, up: Vector3) {
        
        self.position = pos.normalized()
        self.direction = dir.normalized()
        self.up = up.normalized()

    }
    
    func setPos(_ pos:Vector3){
        if pos != self.position { self.trafo = nil}
        self.position = pos
    }
    func setDir(_ dir:Vector3){
        if dir != self.direction{ self.trafo=nil }
        self.direction = dir
    }
    func setUp(_ up: Vector3){
        if up != self.up{ self.trafo = nil }
        self.up = up
    }
    func getTrafo() -> CameraTransformation{
        if let trafo = self.trafo{
            return trafo
        } else {
            self.trafo = CameraTransformation(camera:self)
            return self.getTrafo()
        }
    }
    
    
}

struct CameraTransformation {
    
    let rotationMatrix: simd_float4x4
    
    init(camera: Camera) {
        
        ///Creates a 4x4 Matrix, which rotates the entire scene. Specifying where the Camera is, where it looks At and where up is on the screen.
        ///
        
        let diff = Camera.defaultPos - camera.position
        var translation = Matrix.Identity(4)
        translation[0,3] = diff.x
        translation[1,3] = diff.y
        translation[2,3] = diff.z
        
        let directionOrth:Vector3 = camera.direction *-* Camera.defaultDir
        let angle1 = acos((camera.direction ** Camera.defaultDir))
        let rotation1 = Matrix.matrix4x4_rotation(radians: angle1, axis: directionOrth)
        
        var upMatrix = Matrix(elements: camera.up.toArray(), columns: 1, rows: 4)
        upMatrix.elements.append(1)
        let newUpMatrix = Matrix.fastDotAdd(A: rotation1, B: upMatrix)
        let newUp = Vector3(x: newUpMatrix[0,0], y:newUpMatrix[1,0], z:newUpMatrix[2,0])
        let upOrth:Vector3 = newUp *-* Camera.defaultUp
        let angle2 = acos((newUp ** Camera.defaultUp))
        let rotation2 = Matrix.matrix4x4_rotation(radians: angle2, axis: upOrth)
        
        let rotation = Matrix.fastDotAdd(alpha:0.01, A:translation, B:Matrix.fastDotAdd(A: rotation1, B: rotation2))
        
        self.rotationMatrix = simd_float4x4(simd_float4(rotation[0,0], rotation[0,1], rotation[0,2], rotation[0,3]),
                                            simd_float4(rotation[1,0], rotation[1,1], rotation[1,2], rotation[1,3]),
                                            simd_float4(rotation[2,0], rotation[2,1], rotation[2,2], rotation[2,3]),
                                            simd_float4(rotation[3,0], rotation[3,1], rotation[3,2], rotation[3,3]))
        
    }
    
}
