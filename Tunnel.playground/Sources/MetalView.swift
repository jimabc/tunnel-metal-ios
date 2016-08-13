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
        queue = device!.newCommandQueue()
        
        registerShaders()
        loadTextures()
    }
  
    func registerShaders() {
        do {
            let path = NSBundle.mainBundle().pathForResource("Shaders", ofType: "metal")
            let input = try String(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
            let library = try device!.newLibraryWithSource(input, options: nil)
            let kernel = library.newFunctionWithName("compute")!
            cps = try device!.newComputePipelineStateWithFunction(kernel)
        } catch let e {
            Swift.print("\(e)")
        }
        
        timerBuffer = device!.newBufferWithLength(sizeof(Float), options: [])
    }
    
    func loadTextures() {
        let path = NSBundle.mainBundle().pathForResource("texture", ofType: "tga")
        let textureLoader = MTKTextureLoader(device: device!)
        texture = try! textureLoader.newTextureWithContentsOfURL(NSURL(fileURLWithPath: path!), options: nil)
    }
  
    override public func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        guard let drawable = currentDrawable else {
            return
        }
        
        let commandBuffer = queue.commandBuffer()
        
        let commandEncoder = commandBuffer.computeCommandEncoder()
        commandEncoder.setComputePipelineState(cps)
        commandEncoder.setTexture(drawable.texture, atIndex: 0)
        commandEncoder.setTexture(texture, atIndex: 1)
        commandEncoder.setBuffer(timerBuffer, offset: 0, atIndex: 0)
        
        let threadGroupCount = MTLSizeMake(8, 8, 1)
        let threadGroups = MTLSizeMake(drawable.texture.width / threadGroupCount.width,
                                       drawable.texture.height / threadGroupCount.height, 1)
        
        commandEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)
        commandEncoder.endEncoding()
        
        commandBuffer.presentDrawable(drawable)
        commandBuffer.commit()
        
        update()
    }
    
    func update() {
        timer += 0.01
        let bufferPointer = timerBuffer.contents()
        memcpy(bufferPointer, &timer, sizeof(Float))
    }
}
