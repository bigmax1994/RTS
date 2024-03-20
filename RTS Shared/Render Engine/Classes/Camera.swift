//
//  Camera.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 19.03.24.
//

import Foundation
import simd
import Metal

class Camera {
    
    static let defaultPos: Vector3 = Vector3(x: 0, y: 0, z: 0)
    static let defaultDir: Vector3 = Vector3(x: 0, y: 0, z: 1)
    static let defaultUp: Vector3 = Vector3(x: 0, y: 1, z: 0)
    
    static let defaultAspectRatio: Float = 1
    static let defaultFieldOfView: Float = Float.pi / 2
    static let defaultNearClip: Float = 0
    static let defaultFarClip: Float = 1
    
    private var _position: Vector3
    private var _direction: Vector3
    private var _up: Vector3
    
    private var _aspectRatio: Float
    private var _fieldOfView: Float
    
    private var _nearClip: Float
    private var _farClip: Float
    
    var transformationBuffer: MTLBuffer? = nil
    
    init(pos: Vector3 = Camera.defaultPos, 
         dir: Vector3 = Camera.defaultDir,
         up: Vector3 = Camera.defaultUp,
         aspectRatio: Float = Camera.defaultAspectRatio,
         fov: Float = Camera.defaultFieldOfView,
         nearClip: Float = Camera.defaultNearClip,
         farClip: Float = Camera.defaultFarClip) {
        
        self._position = pos
        self._direction = dir.normalized()
        self._up = up.normalized()
        
        self._aspectRatio = aspectRatio
        self._fieldOfView = fov
        
        self._nearClip = nearClip
        self._farClip = farClip

    }
    
    var position: Vector3 {
        
        get {
            return self._position
        }
        set {
            if newValue == self._position { return }
            self._position = newValue
            self.transformationBuffer = self.createTrafoBuffer()
        }
        
    }
    var direction: Vector3 {
        
        get {
            return self._direction
        }
        set {
            if newValue == self._direction { return }
            self._direction = newValue
            self.transformationBuffer = self.createTrafoBuffer()
        }
        
    }
    var up: Vector3 {
        
        get {
            return self._up
        }
        set {
            if newValue == self._up { return }
            self._up = newValue
            self.transformationBuffer = self.createTrafoBuffer()
        }
        
    }
    
    var aspectRatio: Float {
        
        get {
            return self._aspectRatio
        }
        set {
            if newValue == self._aspectRatio { return }
            self._aspectRatio = newValue
            self.transformationBuffer = self.createTrafoBuffer()
        }
        
    }
    var fieldOfView: Float {
        
        get {
            return self._fieldOfView
        }
        set {
            if newValue == self._fieldOfView { return }
            self._fieldOfView = newValue
            self.transformationBuffer = self.createTrafoBuffer()
        }
        
    }
    
    var nearClip: Float {
        
        get {
            return self._nearClip
        }
        set {
            if newValue == self._nearClip { return }
            self._nearClip = newValue
            self.transformationBuffer = self.createTrafoBuffer()
        }
        
    }
    var farClip: Float {
        
        get {
            return self._farClip
        }
        set {
            if newValue == self._farClip { return }
            self._farClip = newValue
            self.transformationBuffer = self.createTrafoBuffer()
        }
        
    }
    
    func createTrafoBuffer() -> MTLBuffer? {
        
        let trafo = CameraTransformation(camera:self)
            
        return Engine.Device.makeBuffer(bytes: [trafo], length: CameraTransformation.bufferSize(count: 1))
        
    }
    
}

struct CameraTransformation: GPUEncodable {
    
    let rotationMatrix: simd_float4x4
    
    init(camera: Camera) {
        ///Creates a 4x4 Matrix, which rotates the entire scene. Specifying where the Camera is, where it looks At and where up is on the screen.
        
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
        
        let rotation = Matrix.fastDotAdd(alpha:1, A:translation, B:Matrix.fastDotAdd(A: rotation1, B: rotation2))
        
        let clipMatrix = Matrix.matrix_perspective_right_hand(fovyRadians: camera.fieldOfView, aspectRatio: camera.aspectRatio, nearZ: camera.nearClip, farZ: camera.farClip)
        
        let m = Matrix.fastDotAdd(A: clipMatrix, B: rotation)
        
        self.rotationMatrix = simd_float4x4(simd_float4(m[0,0], m[0,1], m[0,2], m[0,3]),
                                            simd_float4(m[1,0], m[1,1], m[1,2], m[1,3]),
                                            simd_float4(m[2,0], m[2,1], m[2,2], m[2,3]),
                                            simd_float4(m[3,0], m[3,1], m[3,2], m[3,3]))
        
    }
    
}
