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
    dynamic var restId = ""
    dynamic var dealId = ""
    dynamic var expirationDate = NSDate()
    dynamic var validValue: Int = 0     // 0 = unset, 1 = valid, 2 = expired, 3 = set to delete
    dynamic var venue = Venue()
    dynamic var id = ""
    
    override class func primaryKey() -> String {
        return "id"
    }
}
