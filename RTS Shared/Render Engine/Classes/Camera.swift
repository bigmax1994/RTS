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
    
    static let renderPos: Vector3 = Vector3(x: 0, y: 0, z: 0)
    static let renderDir: Vector3 = Vector3(x: 0, y: 0, z: -1)
    static let renderUp: Vector3 = Vector3(x: 0, y: 1, z: 0)
    
    private static let defaultPos: Vector3 = Vector3(x: 0, y: 0, z: 0)
    private static let defaultDir: Vector3 = Vector3(x: 0, y: 0, z: 1)
    private static let defaultUp: Vector3 = Vector3(x: 0, y: 1, z: 0)
    
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
        
        self.transformationBuffer = self.createTrafoBuffer()

    }
    
    var position: Vector3 {
        
        get {
            return self._position
        }
        set {
            if newValue == self._position { return }
            self._position = newValue.normalized()
            self.transformationBuffer = self.createTrafoBuffer()
        }
        
    }
    var direction: Vector3 {
        
        get {
            return self._direction
        }
        set {
            if newValue == self._direction { return }
            self._direction = newValue.normalized()
            self.transformationBuffer = self.createTrafoBuffer()
        }
        
    }
    var up: Vector3 {
        
        get {
            return self._up
        }
        set {
            if newValue == self._up { return }
            self._up = newValue.normalized()
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
        
        ///MARK: LOOKING AT SCENE FROM SIDE WITH DIR DOWN
        
        //let rotation1 = Matrix.solveForRotation4x4(from: camera.direction, to: Camera.renderDir)
        let rotation1 = Matrix.solveForRotation3x3(from: camera.direction, to: Camera.renderDir)
        
        let newUp = rotation1 * camera.up
        
        let rotation2 = Matrix.solveForRotation3x3(from: newUp, to: Camera.renderUp)
        
        var rotation = rotation2 * rotation1
        
        rotation.addIdentityBlock(1)
        
        let diff = Camera.renderPos - camera.position
        
        rotation[0,3] = diff.x
        rotation[1,3] = diff.y
        rotation[2,3] = -diff.z
        
        let clipMatrix = Matrix.matrix_perspective_right_hand(fovyRadians: camera.fieldOfView, aspectRatio: camera.aspectRatio, nearZ: camera.nearClip, farZ: camera.farClip)
        
        let m = clipMatrix * rotation
        
        self.rotationMatrix = m.matrix4x4ToSIMD()
        
    }
    
}
