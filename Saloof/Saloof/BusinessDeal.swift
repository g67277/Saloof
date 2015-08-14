//
//  BusinessDeal.swift
//  Saloof
//
//  Created by Nazir Shuqair on 8/1/15.
//  Copyright (c) 2015 SNASTek. All rights reserved.
//

import UIKit
import RealmSwift

class BusinessDeal:Object{
    
    dynamic var title = ""
    dynamic var desc = ""
    dynamic var timeLimit = 0
    dynamic var value = 0.0
    dynamic var id = ""
    dynamic var restaurantID = ""
    dynamic var restaurant: ProfileModel?
    dynamic var isActive = false
    
    override static func primaryKey() -> String? {
        return "id"
    }
}