//
//  VenueDeal.swift
//  Saloof
//
//  Created by Angela Smith on 8/3/15.
//  Copyright (c) 2015 SNASTek. All rights reserved.
//

import RealmSwift

class VenueDeal: Object {
    
    // IMPORTANT: Any changes to data model will either require migration (if app has been released to other devices) https://realm.io/docs/swift/latest/#migrations
    // or deletion from device to reset
    
    
    dynamic var name = ""
    dynamic var desc = ""
    dynamic var timeLimit: Int = 0
    dynamic var tier: Int = 0
    dynamic var value: Float = 0.0
    dynamic var isDefault = false
    dynamic var restId = ""
    dynamic var dealId = ""
    dynamic var dealType = 0 // 0 == default, 1 == normal
    dynamic var expirationDate = NSDate()
    dynamic var validValue: Int = 0     // 0 = unset, 1 = valid, 2 = expired, 3 = set to delete
    dynamic var venue = Venue()
    dynamic var id = ""
    
    override class func primaryKey() -> String {
        return "id"
    }
    
}