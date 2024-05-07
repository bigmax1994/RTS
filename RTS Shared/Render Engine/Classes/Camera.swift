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
    
    var cameraTransformation: CameraTransformation!
    
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
            
            self._transformationMatrix = nil
            
            self._buffer = nil
        }
        
    }
    
    func setPosition(_ vec: Vector3) {
        self.position = vec
    }
    
    var direction: Vector3 {
        
        get {
            return self._direction
        }
        set {
            if newValue == self._direction { return }
            self._direction = newValue.normalized()
            
            self._transformationMatrix = nil
            
            self._buffer = nil
        }
        
    }
    var up: Vector3 {
        
        get {
            return self._up
        }
        set {
            if newValue == self._up { return }
            self._up = newValue.normalized()
            
            self._transformationMatrix = nil
            
            self._buffer = nil
        }
        
    }
    
    var aspectRatio: Float {
        
        get {
            return self._aspectRatio
        }
        set {
            if newValue == self._aspectRatio { return }
            self._aspectRatio = newValue
            
            self._clipMatrix = nil
            
            self._buffer = nil
        }
        
    }
    var fieldOfView: Float {
        
        get {
            return self._fieldOfView
        }
        set {
            if newValue == self._fieldOfView { return }
            self._fieldOfView = newValue
            
            self._clipMatrix = nil
            
            self._buffer = nil
        }
        
    }
    
    var nearClip: Float {
        
        get {
            return self._nearClip
        }
        set {
            if newValue == self._nearClip { return }
            self._nearClip = newValue
            
            self._clipMatrix = nil
            
            self._buffer = nil
        }
        
    }
    var farClip: Float {
        
        get {
            return self._farClip
        }
        set {
            if newValue == self._farClip { return }
            self._farClip = newValue
            
            self._clipMatrix = nil
            
            self._buffer = nil
        }
        
    }
    
    private var _transformationMatrix: Matrix? = nil
    private var _clipMatrix: Matrix? = nil
    
    var transformationMatrix: Matrix {
        get {
            if let m = self._transformationMatrix {
                return m
            }
            let rotation1 = Matrix.solveForRotation3x3(from: self.direction, to: Matrix.clipDefaults.dir)
            
            let newUp = rotation1 * self.up
            
            let rotation2 = Matrix.solveForRotation3x3(from: newUp, to: Matrix.clipDefaults.up)
            
            self._transformationMatrix = rotation2 * rotation1
            return self._transformationMatrix!
            
        }
    }
    
    var clipMatrix: Matrix {
        get {
            if let m = self._clipMatrix {
                return m
            }
            self._clipMatrix = Matrix.matrix_perspective_right_hand(fovyRadians: self.fieldOfView, aspectRatio: self.aspectRatio, nearZ: self.nearClip, farZ: self.farClip)
            return self._clipMatrix!
        }
    }
    
    var _buffer: MTLBuffer? = nil
    
    var cameraBuffer: MTLBuffer? {
        get {
            if let b = self._buffer {
                return b
            }
            
            self.cameraTransformation = CameraTransformation(position: self.position.toSIMD(),
                                                             rotationMatrix: self.transformationMatrix.matrix3x3ToSIMD(),
                                                             clipMatrix: self.clipMatrix.matrix4x4ToSIMD())
            
            return Engine.Device.makeBuffer(bytes: [self.cameraTransformation], length: CameraTransformation.bufferSize(count: 1))
        }
    }
    
}

struct CameraTransformation: ShaderType {
    
    var position: simd_float3
    var rotationMatrix: simd_float3x3
    var clipMatrix: simd_float4x4
    
}
