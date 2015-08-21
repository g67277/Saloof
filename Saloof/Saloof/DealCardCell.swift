//
//  DealCardCell.swift
//  Saloof
//
//  Created by Angela Smith on 8/7/15.
//  Copyright (c) 2015 SNASTek. All rights reserved.
//

import UIKit

class DealCardCell: UICollectionViewCell {
    
    
    @IBOutlet weak var locationTitle: UILabel!
    @IBOutlet weak var locationPhone: UILabel!
    @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var dealTitle: UILabel!
    @IBOutlet weak var dealDesc: UILabel!
    @IBOutlet weak var dealValue: UILabel!
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    func setUpVenueDeal(deal: VenueDeal) {
        locationTitle.text = " from \(deal.venueName)"
        /*
        if deal.hasImage {
            locationImage.image = deal.image
        } else {
            // set up default image
            locationImage.image = UIImage(named: "redHen")
        }*/
        locationImage.imageFromUrl(deal.venueImageUrl)
        //locationImage.image = deal.venue.image
        dealTitle.text = deal.name
        dealDesc.text = deal.desc
        // Set up the value
        let valueFloat:Float = deal.value, valueFormat = ".2"
        dealValue.text = "$\(valueFloat.format(valueFormat)) value"
    }
    
    
}

extension Float {
    func format(f: String) -> String {
        return NSString(format: "%\(f)f", self) as String
    }
}