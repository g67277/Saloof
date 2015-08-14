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
                if object["weekdayHours"] != nil{
                    var weekDay = object["weekdayHours"].string!
                    data!.weekdayHours = weekDay
                }
                if object["weekendHours"] != nil{
                    var weekEnd = object["weekendHours"].string!
                    data!.weekendHours = weekEnd
                }
                if object["defaultPicUrl"] != nil{
                    var imgID = object["defaultPicUrl"].string!
                    data!.imgUri = imgID
                }
                if object["location"] != nil{
                    var street = object["location"]["address"].string!
                    var city = object["location"]["city"].string!
                    var zipcode = object["location"]["postalcode"].string!
                    var lat = object["location"]["lat"].double!
                    var lng = object["location"]["lng"].double!
                    data?.streetAddress = street
                    data?.city = city
                    data?.zipcode = zipcode.toInt()!
                    data?.lat = lat
                    data?.lng = lng
                }
                if object["phone"] != nil{
                    var num = object["phone"].string!
                    data?.phoneNum = num.toInt()!
                }
                if object["url"] != nil{
                    var url = object["url"].string!
                    data?.website = url
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
                                var bDeal = BusinessDeal()
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
                        data!.dealsCount = count
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
            if object["weekdayHours"] != nil{
                var weekDay = object["weekdayHours"].string!
                restaurant.weekdayHours = weekDay
            }
            if object["weekendHours"] != nil{
                var weekEnd = object["weekendHours"].string!
                restaurant.weekendHours = weekEnd
            }
            if object["defaultPicUrl"] != nil{
                var imageURL = object["defaultPicUrl"].string!
                restaurant.imgUri = imageURL
            }
            if object["location"] != nil{
                var street = object["location"]["address"].string!
                var city = object["location"]["city"].string!
                var zipcode = object["location"]["postalcode"].string!
                var lat = object["location"]["lat"].double!
                var lng = object["location"]["lng"].double!
                restaurant.streetAddress = street
                restaurant.city = city
                restaurant.zipcode = zipcode.toInt()!
                restaurant.lat = lat
                restaurant.lng = lng
            }
            if object["phone"] != nil{
                var num = object["phone"].string!
                restaurant.phoneNum = num.toInt()!
            }
            if object["url"] != nil{
                var url = object["url"].string!
                restaurant.website = url
            }

            restaurant.id = prefs.stringForKey("restID")!
            
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
                            var bDeal = BusinessDeal()
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
                    restaurant.dealsCount = count

                }
                
            }
            realm.write({
                realm.add(restaurant, update: false)
            })
        }
    }
    
}