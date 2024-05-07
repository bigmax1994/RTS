//
//  Text.swift
//  RTS
//
//  Created by Max Gasslitter Strobl on 07.04.24.
//

import Foundation
import Metal
import CoreImage

class Text: UIObject {

    private var _string: String
    var string: String {
        get {
            return self._string
        }
        set {
            self._string = newValue
            self._texture = nil
        }
    }
    
    private var _frame: CGRect
    var frame: CGRect {
        get {
            return _frame
        }
        set {
            self._frame = newValue
            
            self.makeVerticies()
        }
    }
    
    private var imgRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    private var _texture: MTLTexture? = nil
    private var texture: MTLTexture? {
        get {
            if let tex = self._texture {
                return tex
            }
            
            let attrString = NSAttributedString(string: self.string, attributes: [.foregroundColor: CGColor.white])
            guard let textImage = CIFilter(name: "CIAttributedTextImageGenerator", parameters: [
                "inputText": attrString
            ])?.outputImage else {
                return nil
            }
            //let textImage = CIImage(color: CIColor.clear).cropped(to: Text.imgRect).premultiplyingAlpha()
            
            self.imgRect = textImage.extent
            //try! Engine.CIContext.pngRepresentation(of: textImage, format: .RGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())?.write(to: URL(fileURLWithPath: "/Users/maxgasslitterstrobl/Downloads/test1.png"))
            
            let textDesc = MTLTextureDescriptor()
            textDesc.pixelFormat = Engine.pixelFormat
            textDesc.width = Int(self.imgRect.width * 10)
            textDesc.height = Int(self.imgRect.height * 10)
            textDesc.usage = [.shaderRead, .shaderWrite]
            
            self._texture = Engine.Device.makeTexture(descriptor: textDesc)
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            
            Engine.CIContext.render(textImage, to: self._texture!, commandBuffer: nil, bounds: self.imgRect, colorSpace: colorSpace)
            
            //let img = CIImage.init(mtlTexture: self._texture!)!
            //try! Engine.CIContext.pngRepresentation(of: img, format: .RGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())?.write(to: URL(fileURLWithPath: "/Users/maxgasslitterstrobl/Downloads/test2.png"))
            
            return self._texture
        }
    }
    
    private var verticies: [TexturedVertex] = []
    private var vertexBuffer: MTLBuffer? = nil
    
    init(_ string: String, frame: CGRect) {
        self._string = string
        self._frame = frame
        
        self.makeVerticies()
    }
    
    func draw(to encoder: any MTLRenderCommandEncoder, with inputs: inout [ShaderTypes : ShaderContainer]) {
        
        guard let texture = self.texture else {
            NSLog("failed to get Texture in Text Render")
            return
        }
        inputs.updateValue(.texture([texture]), forKey: .Texture)
        
        guard let vertexBuffer = self.vertexBuffer else {
            NSLog("failed to make vertex buffer")
            return
        }
        inputs.updateValue(.buffer(vertexBuffer), forKey: .TextureVertex)
        
        Engine.encodeRenderCommand(inputs: inputs, pipeline: .texture, stencil: .always, encoder: encoder)
        encoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: self.verticies.count)
        
    }
    
    private func makeVerticies() {
        
        self.verticies = TexturedVertex.makeStripQuad(in: self.frame, textureSize: self.imgRect)
        
        self.vertexBuffer = Engine.Device.makeBuffer(bytes: verticies, length: TexturedVertex.bufferSize(count: verticies.count))
        
    }
    
}
