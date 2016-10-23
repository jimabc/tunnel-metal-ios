//
//  MetalView.swift
//  Tunnel
//
//  Created by James Matteson on 7/9/16.
//  Copyright © 2016 James Matteson. All rights reserved.
//

import MetalKit

public class MetalView: MTKView {
    
    var queue: MTLCommandQueue! = nil
    var cps: MTLComputePipelineState! = nil
    var rps: MTLRenderPipelineState! = nil
    var timer: Float = 0
    var timerBuffer: MTLBuffer!
    var texture: MTLTexture!
    
    required public init(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    override public init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device)
        
        setup()
    }
    
    func setup() {
        queue = device!.makeCommandQueue()
        framebufferOnly = false
        
        registerShaders()
        loadTextures()
    }
    
    func registerShaders() {
        do {
            let library = device!.newDefaultLibrary()!
            let kernel = library.makeFunction(name: "compute")!
            cps = try device!.makeComputePipelineState(function: kernel)
        } catch let e {
            Swift.print("\(e)")
        }
        
        timerBuffer = device!.makeBuffer(length: MemoryLayout<Float>.size, options: [])
    }
    
    func loadTextures() {
        let path = Bundle.main.path(forResource: "texture", ofType: "tga")
        let textureLoader = MTKTextureLoader(device: device!)
        texture = try! textureLoader.newTexture(withContentsOf: URL(fileURLWithPath: path!), options: nil)
    }
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let
            drawable = currentDrawable else {
                return
        }
        
        let commandBuffer = queue.makeCommandBuffer()
        
        let commandEncoder = commandBuffer.makeComputeCommandEncoder()
        commandEncoder.setComputePipelineState(cps)
        commandEncoder.setTexture(drawable.texture, at: 0)
        commandEncoder.setTexture(texture, at: 1)
        commandEncoder.setBuffer(timerBuffer, offset: 0, at: 0)
        
        let threadGroupCount = MTLSizeMake(8, 8, 1)
        let threadGroups = MTLSizeMake(drawable.texture.width / threadGroupCount.width,
                                       drawable.texture.height / threadGroupCount.height, 1)
        
        commandEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)
        commandEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
        
        update()
    }
    
    func update() {
        timer += 0.01
        let bufferPointer = timerBuffer.contents()
        memcpy(bufferPointer, &timer, MemoryLayout<Float>.size)
    }
}
