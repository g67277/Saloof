//
//  JSONParser.swift
//  Saloof
//
//  Created by Nazir Shuqair on 8/10/15.
//  Copyright (c) 2015 SNASTek. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

public class JSONParser {
    
    
    class func parseJSON(json: JSON, source: String) {
        let realm = try! Realm()
        
        if let deals = json["deals"].array {
            for deal in deals {
                // make sure it is active
                let isActive = deal["active"].boolValue
                if isActive {
                    let venueDeal = VenueDeal()
                    venueDeal.name = deal["title"].stringValue
                    venueDeal.desc = deal["description"].stringValue
                    venueDeal.tier = deal["tier"].intValue
                    venueDeal.timeLimit = deal["timeLimit"].intValue
                    venueDeal.value = deal["deal_value"].floatValue
                    venueDeal.id = deal["id"].stringValue
                    //venueDeal.venue = venue
                    venueDeal.restId = json["Id"].stringValue
                    venueDeal.venueName = json["name"].stringValue
                    venueDeal.venuePriceTier = json["priceTier"].intValue
                    let imageUrlString = json["defaultPicUrl"].stringValue
                    
                    let imageUrl = NSURL(string: imageUrlString)
                    if let data = NSData(contentsOfURL: imageUrl!){
                        venueDeal.hasImage = true
                        let venueImage = UIImage(data: data)
                        venueDeal.image = venueImage
                    }
                    
                    // check for current object
                    // Query using a predicate string
                    let dealPreviouslyDisplayed = realm.objectForPrimaryKey(VenueDeal.self, key: venueDeal.id)
                    if (dealPreviouslyDisplayed != nil) {
                        //println("This is a previously pulled deal, checking dates")
                        // we need to check the date
                        let expiresTime = dealPreviouslyDisplayed?.expirationDate
                        // see how much time has lapsed
                        let compareDates: NSComparisonResult = NSDate().compare(expiresTime!)
                        if compareDates == NSComparisonResult.OrderedAscending {
                            // the deal has not expired yet
                        } else {
                            //the deal has expired
                            // TODO: If deal is over 3 hours old, delete it immedietly and reload
                            venueDeal.validValue = 2
                            // update the db
                            realm.write {
                                realm.create(VenueDeal.self, value: venueDeal, update: true)
                            }
                        }
                    } else {
                        // println("This is a new deal, setting expiration date")
                        // set date of expiration
                        let firstLoad = NSDate()
                        // add time based on expiration
                        var time: NSTimeInterval = 0
                        switch deal[Constants.dealExpires].intValue {
                        case 2 :
                            time = 7200
                        case 3 :
                            time = 10800
                        default:
                            time = 3600
                        }
                        //println(time)
                        let dealExpires = firstLoad.dateByAddingTimeInterval(time)
                        venueDeal.expirationDate = dealExpires
                        venueDeal.validValue = 1
                        // write to db
                        realm.write {
                            realm.create(VenueDeal.self, value: venueDeal, update: true)
                        }
                    }
                    
                    
                }
                
                
            }
        }
    }
}