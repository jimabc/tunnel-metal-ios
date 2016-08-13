//
//  ViewController.swift
//  Tunnel
//
//  Created by James Matteson on 7/9/16.
//  Copyright © 2016 James Matteson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var largestDimension: CGFloat {
        let screen = UIScreen.mainScreen()
        return fmax(screen.bounds.width, screen.bounds.height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let device = MTLCreateSystemDefaultDevice()!
        let metalView = MetalView(frame: CGRectZero, device: device)
        metalView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(metalView)
        view.addConstraints([
            view.centerXAnchor.constraintEqualToAnchor(metalView.centerXAnchor),
            view.centerYAnchor.constraintEqualToAnchor(metalView.centerYAnchor)
        ])
        
        let width = NSLayoutConstraint(item: metalView,
                                       attribute: .Width,
                                       relatedBy: .Equal,
                                       toItem: nil,
                                       attribute: .NotAnAttribute,
                                       multiplier: 1.0,
                                       constant: largestDimension)
        
        let square = NSLayoutConstraint(item: metalView,
                                        attribute: .Width,
                                        relatedBy: .Equal,
                                        toItem: metalView,
                                        attribute: .Height,
                                        multiplier: 1.0,
                                        constant: 0.0)
        
        metalView.addConstraints([width, square])
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
