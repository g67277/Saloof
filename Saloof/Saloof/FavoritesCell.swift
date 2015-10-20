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
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var fsPriceLabel: UILabel!
    @IBOutlet weak var fsDistanceLabel: UILabel!
    @IBOutlet weak var locationImage: UIImageView!
    
    @IBOutlet var likesBarView: UIView!
    
    @IBOutlet var foursquareBarView: UIView!
    
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
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setUpCell(name: String, phone: String, imageUrl: String){
        
        locationTitle.text = name
        locationPhone.text = phone
    }
    
    func setImageWithURL(imgAddress: String) {
        locationImage?.setImageCacheWithAddress(imgAddress, placeHolderImage: UIImage (named: "placeholder")!)
    }
    
    func setUpFoursquareBar(price: Int, distance: String) {
        likesBarView.hidden = true
        foursquareBarView.hidden = false
        print("price \(price)", terminator: "")
        // Number Labels
        if var _ = fsPriceLabel {
            var priceString = ""
            switch price {
            case 0:
                priceString = ""
            case 1:
                priceString = "$"
            case 2:
                priceString = "$$"
            case 3:
                priceString = "$$$"
            case 4:
                priceString = "$$$$"
            default:
                priceString = ""
            }
            fsPriceLabel.text = priceString
        }
        if let distanceLab = fsDistanceLabel {
            distanceLab.text = (distance == "1.0") ? "\(distance) mile" : "\(distance) miles"
        }
        
    }

    
    func setUpLikesBar(likes: Int, favorites: Int, price: Int, distance: String) {
        likesBarView.hidden = false
        foursquareBarView.hidden = true
        likesLabel.text = " \(likes)"
        favoritesLabel.text = " \(favorites)"
        // Number Labels
        if var _ = priceLabel {
            var priceString = ""
            switch price {
            case 0:
                priceString = ""
            case 1:
                priceString = "$"
            case 2:
                priceString = "$$"
            case 3:
                priceString = "$$$"
            case 4:
                priceString = "$$$$"
            default:
                priceString = ""
            }
            priceLabel.text = priceString
        }
        if let distanceLab = distanceLabel {
            let distance = distance
            distanceLab.text = (distance == "1.0") ? "\(distance) mile" : "\(distance) miles"
        }
        
    }
}
