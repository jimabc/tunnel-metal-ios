//
//  ViewController.swift
//  Tunnel
//
//  Created by James Matteson on 7/9/16.
//  Copyright © 2016 James Matteson. All rights reserved.
//

import MetalKit
import UIKit

class ViewController: UIViewController {
    
    var largestDimension: CGFloat {
        let screen = UIScreen.main
        return fmax(screen.bounds.width, screen.bounds.height)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let device = MTLCreateSystemDefaultDevice()!
        let metalView = MetalView(frame: CGRect.zero, device: device)
        metalView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(metalView)
        view.addConstraints([
            view.centerXAnchor.constraint(equalTo: metalView.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: metalView.centerYAnchor)
        ])
        
        let width = NSLayoutConstraint(item: metalView,
                                       attribute: .width,
                                       relatedBy: .equal,
                                       toItem: nil,
                                       attribute: .notAnAttribute,
                                       multiplier: 1.0,
                                       constant: largestDimension)
        
        let square = NSLayoutConstraint(item: metalView,
                                        attribute: .width,
                                        relatedBy: .equal,
                                        toItem: metalView,
                                        attribute: .height,
                                        multiplier: 1.0,
                                        constant: 0.0)
        
        metalView.addConstraints([width, square])
    }
}
