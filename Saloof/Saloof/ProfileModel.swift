//
//  ProfileModel.swift
//  Saloof
//
//  Created by Nazir Shuqair on 8/7/15.
//  Copyright (c) 2015 SNASTek. All rights reserved.
//


import UIKit
import RealmSwift

class ProfileModel:Object{
    
    dynamic var restaurantName = ""
    dynamic var phoneNum = ""
    dynamic var website = ""
    dynamic var streetAddress = ""
    dynamic var city = ""
    dynamic var zipcode = 0
    dynamic var lat = 0.0
    dynamic var lng = 0.0
    dynamic var priceTier = 0
    dynamic var weekdayO = ""
    dynamic var weekdayC = ""
    dynamic var weekendO = ""
    dynamic var weekendC = ""
    dynamic var weekdayHours = ""
    dynamic var weekendHours = ""
    dynamic var category = ""
    dynamic var imgUri = ""
    dynamic var contactName = ""
    dynamic var desc = ""
    dynamic var dealsCount = 0
    dynamic var id = ""
    let deals = List<BusinessDeal>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}