//
//  GradientView.swift
//  Saloof
//
//  Created by Angela Smith on 8/8/15.
//  Copyright (c) 2015 SNASTek. All rights reserved.
//

import UIKit

class GradientView: UIView {
    // Subclass of uiview thal creates a vertical clear to dark grey gradient so the white text label placed over an image can be read
    private let gradient : CAGradientLayer = CAGradientLayer()
    
    
    override func awakeFromNib() {
        
        // Keep the gradient within the layer
        self.layer.masksToBounds = true
        
        // set up the colors
        let darkGrey = UIColor.darkGrayColor().CGColor
        let clear = UIColor.clearColor().CGColor
        
        if self.tag == 0 {
            // under restaurant image
            // set gradient's color array
            gradient.colors = [clear, darkGrey]
        } else {
            // This is on the initial screen
            // reverse gradient's color array
            gradient.colors = [clear, darkGrey, clear]
        }
        // add the layer to the UIView
        self.layer.insertSublayer(gradient, atIndex: 0)
    }
    
    // Relay out subviews for auto constraints
    override func layoutSublayersOfLayer(layer: CALayer) {
        super.layoutSublayersOfLayer(layer)
        gradient.frame = self.bounds
    }
}