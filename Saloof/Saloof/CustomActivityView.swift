//
//  CustomActivityView.swift
//  activityIndicatorTest
//
//  Created by Angela Smith on 8/5/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//  Adapted from NVIndicatorView

import UIKit

class CustomActivityView: UIView {

    private let defaultColor = UIColor.whiteColor()
    private let defaultSize: CGSize = CGSize(width: 70, height: 70)
    
    private var color: UIColor
    private var size: CGSize
    
    var animating: Bool = false
    
    required init(coder aDecoder: NSCoder) {
        self.color = defaultColor
        self.size = defaultSize
        super.init(coder: aDecoder);
    }
    
    init(frame: CGRect, color: UIColor?, size: CGSize?) {
        self.color = defaultColor
        self.size = defaultSize
        super.init(frame: frame)
        
        if let _color = color {
            self.color = _color
        }
        if let _size = size {
            self.size = _size
        }
    }
    
    
    func startAnimation() {
        if (self.layer.sublayers == nil) {
            setUpAnimationInLayer(self.layer, size: self.size, color: self.color)
        }
        self.layer.speed = 1
        self.animating = true
    }
    
    func stopAnimation() {
        self.layer.speed = 0
        self.animating = false
    }
    
    
    func setUpAnimationInLayer(layer: CALayer, size: CGSize, color: UIColor) {
        let circleSpacing: CGFloat = 4
        let circleSize = (size.width - circleSpacing * 2) / 3
        let x = (layer.bounds.size.width - size.width) / 2
        let y = (layer.bounds.size.height - size.height) / 2
        let durations = [0.96, 0.93, 1.19, 1.13, 1.34, 0.94, 1.2, 0.82, 1.19]
        let beginTime = CACurrentMediaTime()
        let beginTimes = [0.36, 0.4, 0.68, 0.41, 0.71, -0.15, -0.12, 0.01, 0.32]
        let timing = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        
        // Animation
        let animation = CAKeyframeAnimation(keyPath: "opacity")
        
        animation.keyTimes = [0, 0.5, 1]
        animation.timingFunctions = [timing, timing]
        animation.values = [1, 0.7, 1]
        animation.repeatCount = HUGE
        animation.removedOnCompletion = false
        
        
        // Draw top row of three circles
        for var i = 0; i < 3; i++ {
            // create the ring
            let circle = createRingLayer(size: CGSize(width: circleSize, height: circleSize), color: color)
            // create the frame
            let frame = CGRect(x: x + circleSize * CGFloat(i) + circleSpacing * CGFloat(i), y: y, width: circleSize, height: circleSize)
            animation.duration = durations[3 * i]
            animation.beginTime = beginTime + beginTimes[3 * i]
            circle.frame = frame
            circle.addAnimation(animation, forKey: "animation")
            layer.addSublayer(circle)
        }
        // Draw second row of two circles
        for var i = 0; i < 2; i++ {
            // create the ring
            let circle = createRingLayer(size: CGSize(width: circleSize, height: circleSize), color: color)
            // create the frame
            let frame = CGRect(x: x + (circleSize / 2 + circleSpacing) + circleSize * CGFloat(i) + circleSpacing * CGFloat(i), y: y + circleSize + circleSpacing, width: circleSize, height: circleSize)
            animation.duration = durations[3 * i]
            animation.beginTime = beginTime + beginTimes[3 * i]
            circle.frame = frame
            circle.addAnimation(animation, forKey: "animation")
            layer.addSublayer(circle)
        }
        // Draw last circle
        for var i = 0; i < 1; i++ {
            // create the ring
            let circle = createRingLayer(size: CGSize(width: circleSize, height: circleSize), color: color)
            // create the frame
            let frame = CGRect(x: x + (circleSize + circleSpacing) + circleSize * CGFloat(i) + circleSpacing * CGFloat(i), y: y + (circleSize + circleSpacing) * 2, width: circleSize, height: circleSize)
            animation.duration = durations[3 * i]
            animation.beginTime = beginTime + beginTimes[3 * i]
            circle.frame = frame
            circle.addAnimation(animation, forKey: "animation")
            layer.addSublayer(circle)
        }


    }
    
    func createRingLayer(# size: CGSize, color: UIColor) -> CALayer {
        let layer: CAShapeLayer = CAShapeLayer()
        var path: UIBezierPath = UIBezierPath()
        let lineWidth: CGFloat = 2
        
        
        path.addArcWithCenter(CGPoint(x: size.width / 2, y: size.height / 2),
            radius: size.width / 2,
            startAngle: 0,
            endAngle: CGFloat(2 * M_PI),
            clockwise: false);
        layer.fillColor = nil
        layer.strokeColor = color.CGColor
        layer.lineWidth = lineWidth
        
        
        layer.backgroundColor = nil
        layer.path = path.CGPath
        
        return layer
    }


    
}
