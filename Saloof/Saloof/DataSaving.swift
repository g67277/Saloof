//
//  DataSaving.swift
//  Saloof
//
//  Created by Nazir Shuqair on 8/8/15.
//  Copyright (c) 2015 SNASTek. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

public class DataSaving{
    
    class func saveRestaurantProfile(object: JSON){
        
        let restArray = try! Realm().objects(ProfileModel)
        let dealArray = try! Realm().objects(BusinessDeal)
        let realm = try! Realm()
        let prefs: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var updateObject = false
        
        for restaurant in restArray{
            if restaurant.id == prefs.stringForKey("restID"){
                updateObject = true
                break
            }
        }
        
        if updateObject {
            let data =
            try! Realm().objectForPrimaryKey(ProfileModel.self, key: prefs.stringForKey("restID")!)
            realm.write({
                if object["name"] != nil{
                    data!.restaurantName = object["name"].string!
                }
                if object["priceTier"] != nil{
                    data!.priceTier = object["priceTier"].int!
                }
                if object["contactName"] != nil{
                    data!.contactName = object["contactName"].string!
                }
                if object["category"] != nil{
                    let category = object["category"]["name"].string!
                    data!.category = category
                }
                if object["weekdayHours"] != nil{
                    let weekDay = object["weekdayHours"].string!
                    data!.weekdayHours = weekDay
                }
                if object["weekendHours"] != nil{
                    let weekEnd = object["weekendHours"].string!
                    data!.weekendHours = weekEnd
                }
                if object["defaultPicUrl"] != nil{
                    let imgID = object["defaultPicUrl"].string!
                    data!.imgUri = imgID
                }
                if object["location"] != nil{
                    let street = object["location"]["address"].string!
                    let city = object["location"]["city"].string!
                    let zipcode = object["location"]["postalcode"].string!
                    let lat = object["location"]["lat"].double!
                    let lng = object["location"]["lng"].double!
                    data?.streetAddress = street
                    data?.city = city
                    data?.zipcode = Int(zipcode)!
                    data?.lat = lat
                    data?.lng = lng
                }
                if object["phone"] != nil{
                    data!.phoneNum = object["phone"].string!
                    //var num = object["phone"].string!
                    //data?.phoneNum = num.toInt()!
                }
                if object["url"] != nil{
                    let url = object["url"].string!
                    data?.website = url
                }
                
                if prefs.integerForKey("DealCount") > 0 {
                    prefs.setInteger(0, forKey: "DealCount")
                    prefs.synchronize()
                }
                
                if object["deals"] != nil{
                    
                    if let deals = object["deals"].array {
                        var count = 0
                        for deal in deals {
                            var exists = false
                            for localDeal in dealArray{
                                if localDeal.id.lowercaseString == deal["id"].string!{
                                    exists = true
                                    break
                                }else{
                                    exists = false
                                }
                            }
                            if !exists{
                                let bDeal = BusinessDeal()
                                bDeal.title = deal["title"].string!
                                bDeal.desc = deal["description"].string!
                                bDeal.value = deal["deal_value"].double!
                                bDeal.timeLimit = deal["timeLimit"].int!
                                bDeal.id = deal["id"].string!
                                bDeal.restaurantID = deal["venue_id"].string!
                                data!.deals.append(bDeal)
                            }
                            count++
                        }
                        prefs.setInteger(count, forKey: "DealCount")
                        prefs.synchronize()
                        data!.dealsCount = count
                    }
                    
                }
                
            })
        }else{
            
            let restaurant = ProfileModel()
            
            if object["name"] != nil{
                restaurant.restaurantName = object["name"].string!
            }
            if object["priceTier"] != nil{
                restaurant.priceTier = object["priceTier"].int!
            }
            if object["contactName"] != nil{
                restaurant.contactName = object["contactName"].string!
            }
            if object["category"] != nil{
                let category = object["category"]["name"].string!
                restaurant.category = category
            }
            if object["weekdayHours"] != nil{
                let weekDay = object["weekdayHours"].string!
                restaurant.weekdayHours = weekDay
            }
            if object["weekendHours"] != nil{
                let weekEnd = object["weekendHours"].string!
                restaurant.weekendHours = weekEnd
            }
            if object["defaultPicUrl"] != nil{
                let imageURL = object["defaultPicUrl"].string!
                restaurant.imgUri = imageURL
            }
            if object["location"] != nil{
                let street = object["location"]["address"].string!
                let city = object["location"]["city"].string!
                let zipcode = object["location"]["postalcode"].string!
                let lat = object["location"]["lat"].double!
                let lng = object["location"]["lng"].double!
                restaurant.streetAddress = street
                restaurant.city = city
                restaurant.zipcode = Int(zipcode)!
                restaurant.lat = lat
                restaurant.lng = lng
            }
            if object["phone"] != nil{
                 restaurant.phoneNum = object["phone"].string!
                //var num = object["phone"].string!
                //restaurant.phoneNum = num.toInt()!
            }
            if object["url"] != nil{
                let url = object["url"].string!
                restaurant.website = url
            }

            restaurant.id = prefs.stringForKey("restID")!
            
            if prefs.integerForKey("DealCount") > 0 {
                prefs.setInteger(0, forKey: "DealCount")
                prefs.synchronize()
            }
            
            if object["deals"] != nil{
                
                if let deals = object["deals"].array {
                    var count = 0
                    for deal in deals {
                        var exists = false
                        for localDeal in dealArray{
                            if localDeal.id == deal["id"].string!{
                                exists = true
                                break
                            }else{
                                exists = false
                            }
                        }
                        if !exists{
                            let bDeal = BusinessDeal()
                            bDeal.title = deal["title"].string!
                            bDeal.desc = deal["description"].string!
                            bDeal.value = deal["deal_value"].double!
                            bDeal.timeLimit = deal["timeLimit"].int!
                            bDeal.id = deal["id"].string!
                            bDeal.restaurantID = deal["venue_id"].string!
                            restaurant.deals.append(bDeal)
                        }
                        count++
                    }
                    prefs.setInteger(count, forKey: "DealCount")
                    prefs.synchronize()
                    restaurant.dealsCount = count

                }
                
            }
            realm.write({
                realm.add(restaurant, update: false)
            })
        }
    }
    
}