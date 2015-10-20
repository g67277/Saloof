//
//  DealsCell.swift
//  Saloof
//
//  Created by Nazir Shuqair on 7/18/15.
//  Copyright (c) 2015 SNASTek. All rights reserved.
//

import UIKit
import AssetsLibrary
import RealmSwift

class DealsCell: UITableViewCell {
    
    @IBOutlet weak var dealTitle: UILabel!
    @IBOutlet weak var dealDesc: UILabel!
    @IBOutlet weak var timeLimit: UILabel!
    @IBOutlet weak var dealValue: UILabel!
    @IBOutlet weak var tierLabel: UILabel!
    @IBOutlet weak var dealImg: UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func refreshCell(title: String, desc: String, time: Int, value: String, tier: Int, img: UIImage){
        
        dealTitle.text = title
        dealDesc.text = desc
        if time < 2 {
            timeLimit.text = "\(time)hr limit"
        }else{
            timeLimit.text = "\(time)hrs limit"
        }
        dealValue.text = value
        tierLabel.text = "Tier \(tier)"
        
        dealImg.image = img
        dealImg.layer.masksToBounds = false
        dealImg.layer.borderColor = UIColor.blackColor().CGColor
        dealImg.layer.cornerRadius = dealImg.frame.height/2
        dealImg.clipsToBounds = true
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
