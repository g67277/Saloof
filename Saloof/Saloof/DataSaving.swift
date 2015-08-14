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
        
        var restArray = Realm().objects(ProfileModel)
        var dealArray = Realm().objects(BusinessDeal)
        let realm = Realm()
        let prefs: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var updateObject = false
        
        for restaurant in restArray{
            if restaurant.id == prefs.stringForKey("restID"){
                updateObject = true
                break
            }
        }
        
        if updateObject {
            var data = Realm().objectForPrimaryKey(ProfileModel.self, key: prefs.stringForKey("restID")!)
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
                    var category = object["category"]["name"].string!
                    data!.category = category
                }
                
                if object["deals"] != nil{
                    
                    if let deals = object["deals"].array {
                        for deal in deals {
                            var exists = false
                            for localDeal in dealArray{
                                println("localID id:\(localDeal.id)")
                                var test = deal["id"].string!
                                println("incoming id:\(test)")
                                if localDeal.id.lowercaseString == deal["id"].string!{
                                    exists = true
                                    break
                                }else{
                                    exists = false
                                }
                            }
                            if !exists{
                                var bDeal = BusinessDeal()
                                bDeal.title = deal["title"].string!
                                bDeal.desc = deal["description"].string!
                                bDeal.value = deal["deal_value"].double!
                                bDeal.timeLimit = deal["timeLimit"].int!
                                bDeal.id = deal["id"].string!
                                bDeal.restaurantID = deal["venue_id"].string!
                                data!.deals.append(bDeal)
                            }
                        }
                    }
                    
                }
                
            })
        }else{
            
            var restaurant = ProfileModel()
            
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
                var category = object["category"]["name"].string!
                restaurant.category = category
            }
            restaurant.id = prefs.stringForKey("restID")!
            
            if object["deals"] != nil{
                
                if let deals = object["deals"].array {
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
                            var bDeal = BusinessDeal()
                            bDeal.title = deal["title"].string!
                            bDeal.desc = deal["description"].string!
                            bDeal.value = deal["deal_value"].double!
                            bDeal.timeLimit = deal["timeLimit"].int!
                            bDeal.id = deal["id"].string!
                            bDeal.restaurantID = deal["venue_id"].string!
                            restaurant.deals.append(bDeal)
                        }
                    }
                }
                
            }
            
            realm.write({
                realm.add(restaurant, update: false)
            })
            
            
        }
        
        
        //        if object["weekdayHours"] != nil{
        //            restaurant.weekdayHours = object["weekdayHours"] as! String
        //            if let space = find(restaurant.weekdayHours, " ") {
        //                let substr = restaurant.weekdayHours[restaurant.weekdayHours.startIndex..<space]
        //                // substr will be "Hello"
        //            }
        //        }
        //        if object["weekendHours"] != nil{
        //            restaurant.weekendHours = object["weekendHours"] as! String
        //        }
    }
    
}