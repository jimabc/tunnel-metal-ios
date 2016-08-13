import MetalKit
import XCPlayground

let size = 512.0
let device = MTLCreateSystemDefaultDevice()!
let frame = CGRect(x:0, y:0, width:size, height:size)
let view = MetalView(frame: frame, device: device)
XCPlaygroundPage.currentPage.liveView = view