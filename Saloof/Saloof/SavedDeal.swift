//
//  SavedDeal.swift
//  Saloof
//
//  Created by Angela Smith on 8/3/15.
//  Copyright (c) 2015 SNASTek. All rights reserved.
//

import RealmSwift

class SavedDeal: Object {
    
    dynamic var name = ""
    dynamic var desc = ""
    dynamic var timeLimit: Int = 0
    dynamic var tier: Int = 0
    dynamic var value: Float = 0.0
    dynamic var isDefault = false
    dynamic var dealId = ""
    dynamic var dealType = 0 // 0 == default, 1 == normal
    dynamic var expirationDate = NSDate()
    dynamic var validValue: Int = 0     // 0 = unset, 1 = valid, 2 = expired, 3 = set to delete
    
    // venue
    dynamic var hasImage: Bool = false
    dynamic var imageData: NSData = NSData()
    dynamic var restId = ""
    dynamic var venuePriceTier: Int = 0
    dynamic var venueImageUrl = ""
    dynamic var venueName = ""
    
    var image: UIImage? {
        get {
            return UIImage(data: imageData)
        }
        set(newImage) {
            if(newImage != nil) {
                imageData = UIImagePNGRepresentation(newImage)
            } else {
                hasImage = false
            }
        }
    }
    // Specify properties to ignore (Realm won't persist)
    override static func ignoredProperties() -> [String] {
        return ["image"]
    }
    
    
    //dynamic var venue = Venue()
    dynamic var id = ""
    
    override class func primaryKey() -> String {
        return "id"
    }
    
}