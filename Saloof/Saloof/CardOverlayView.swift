//
//  CardOverlayView.swift
//  Saloof
//
//  Created by Angela Smith on 7/20/15.
//  Copyright (c) 2015 SNASTek. All rights reserved.
//


// This is the Overlay Class for displaying a transparant image over the tinder like cards when the user swipes them left or right
import UIKit
import Koloda

private let overlayRightImageName = "yesOverlay"
private let overlayLeftImageName = "noOverlay"

class CardOverlayView: OverlayView {
    
    
    @IBOutlet lazy var overlayImageView: UIImageView! = {
        [unowned self] in
        
        var imageView = UIImageView(frame: self.bounds)
        self.addSubview(imageView)
        
        return imageView
        }()
    
    override var overlayState:OverlayMode  {
        didSet {
            //overlayImageView.contentMode = UIViewContentMode.ScaleAspectFill
            //overlayImageView.clipsToBounds = true
            switch overlayState {
            case .Left :
                overlayImageView.image = UIImage(named: overlayLeftImageName)
            case .Right :
                overlayImageView.image = UIImage(named: overlayRightImageName)
            default:
                overlayImageView.image = nil
            }
            
        }
    }
    
}
