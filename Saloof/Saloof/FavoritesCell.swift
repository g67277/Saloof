//
//  FavoritesCell.swift
//  Saloof
//
//
//  FavoritesCell.swift
//  UserSide
//
//  Created by Angela Smith on 7/20/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

import UIKit

class FavoritesCell: UITableViewCell {
    
    @IBOutlet weak var locationTitle: UILabel!
    @IBOutlet weak var locationPhone: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var favoritesLabel: UILabel!
    @IBOutlet weak var priceDistanceLabel: UILabel!
    @IBOutlet weak var locationImage: UIImageView!
    
    @IBOutlet var likesBarView: UIView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setUpCell(name: String, phone: String, image: UIImage){
        
        locationTitle.text = name
        locationPhone.text = phone
        locationImage.image = image
    }
    
    func setUpLikesBar(likes: Int, favorites: Int, price: Int, distance: String) {
        
        likesLabel.text = " \(likes)"
        favoritesLabel.text = " \(favorites)"
        // Number Labels
        if var tierLabel = priceDistanceLabel {
            var priceTierValue = price
            var priceString = ""
            switch priceTierValue {
            case 0:
                priceString = ""
            case 1:
                priceString = "$"
            case 2:
                priceString = "$$"
            case 3:
                priceString = "$$$"
            default:
                priceString = ""
            }
            var distance = distance
            //var miles = userDistance/5280
            //let distance = Int(floor(miles))
            tierLabel.text = (distance == "1.0") ? "  \(priceString)   \(distance) mile" : "\(priceString)  \(distance) miles"
            
        }
        
    }
}
