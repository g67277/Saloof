//
//  CardContentView.swift
//  Saloof

//  Created by Angela Smith on 7/20/15.
//  Copyright (c) 2015 SNASTek. All rights reserved.
//

// This view recieves the restaurant name, image, and phone number and displays it as a UIView over the Koloda view


import UIKit

class CardContentView: UIView {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        // Shadow
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOpacity = 0.33
        layer.shadowOffset = CGSizeMake(0, 1.5)
        layer.shadowRadius = 4.0
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.mainScreen().scale
        
        // Corner Radius
        layer.cornerRadius = 10.0;
    }
    
    func setUpRestaurant(contentView: UIView, dataObject: Venue){
        
        let venue: Venue = dataObject
        if let label = contentView.viewWithTag(10) as? UILabel {
            label.text = venue.name
        }
        if let phoneLabel = contentView.viewWithTag(15) as? UILabel {
            phoneLabel.text = venue.phone
        }
        if let locationImage = contentView.viewWithTag(20) as? UIImageView {
            if venue.hasImage {
                locationImage.contentMode = UIViewContentMode.ScaleAspectFill
                locationImage.clipsToBounds = true
                locationImage.image = venue.image
            } else {
                // set up default image
                locationImage.contentMode = UIViewContentMode.ScaleAspectFill
                locationImage.clipsToBounds = true
                locationImage.image = UIImage(named: "redHen")
            }
        }
    }
    
}

