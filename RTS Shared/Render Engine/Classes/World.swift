//
//  World.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 26.03.24.
//

import Foundation
import Metal

class World {
    
    var settings: WorldSettings
    
    var _settingsBuffer: MTLBuffer? = nil
    
    var settingsBuffer: MTLBuffer? {
        get {
            if let b = self._settingsBuffer {
                return b
            }
            self._settingsBuffer = self.createBuffer()
            return self._settingsBuffer
        }
    }
    
    init(settings: WorldSettings) {
        self.settings = settings
    }
    
    convenience init(sunPos: Vector3 = Vector3(x: 0, y: 0, z: 1), sunColor: Vector3 = Vector3(x: 1, y: 1, z: 1)) {
        let settings = WorldSettings(sunPos: sunPos, sunColor: sunColor)
        self.init(settings: settings)
    }
    
    func createBuffer() -> MTLBuffer? {
        
        if let b = self._settingsBuffer {
            return b
        }
        
        return Engine.Device.makeBuffer(bytes: [self.settings], length: WorldSettings.bufferSize(count: 1))
        
    }
    
}
