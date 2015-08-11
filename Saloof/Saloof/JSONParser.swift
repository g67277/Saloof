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
        let realm = Realm()

        // Create the venue object first
        let venue = Venue()
        venue.identifier = json[Constants.restId].stringValue
        venue.phone = json[Constants.restContactObject][Constants.restContactPhone].stringValue /* Not working*/
        venue.name = json[Constants.restName].stringValue
        venue.webUrl = json[Constants.restUrl].stringValue                       /* Not working*/
        let imagePrefix = json[Constants.restPhotoObject][Constants.restPhotoGroupArray][0][Constants.restPhotoItemsArray][0][Constants.restPhotoPrefix].stringValue
        let imageSuffix = json[Constants.restPhotoObject][Constants.restPhotoGroupArray][0][Constants.restPhotoItemsArray][0][Constants.restPhotoSuffix].stringValue
        let imageName = imagePrefix + "400x400" +  imageSuffix
        var locationAddress = json[Constants.restLocationObject][Constants.restAddressArray][0].stringValue
        var cityAddress = json[Constants.restLocationObject][Constants.restAddressArray][1].stringValue
        venue.address = locationAddress + "\n" + cityAddress
        venue.hours = json[Constants.restHoursObject][Constants.restStats].stringValue
        venue.distance = json[Constants.restLocationObject][Constants.restDistance].floatValue
        venue.priceTier = json[Constants.restPriceObject][Constants.restTier].intValue
        venue.sourceType = source
        venue.swipeValue = 3  // deal only
        venue.favorites = json[Constants.restStats][Constants.restFavorites].intValue
        venue.likes = json[Constants.restStats][Constants.restLikes].intValue
        
        
        // this is a deal only restaurant
        let imageUrl = NSURL(string: imageName)
        if let data = NSData(contentsOfURL: imageUrl!){
            
            let venueImage = UIImage(data: data)
            venue.image = venueImage
        }
        // Then create the deal object and add the venue to it
        if let deals = json[Constants.dealObject][Constants.dealsArray].array {
            for deal in deals {
                let venueDeal = VenueDeal()
                venueDeal.name = deal[Constants.dealTitle].stringValue
                venueDeal.desc = deal[Constants.dealDescription].stringValue
                venueDeal.tier = deal[Constants.dealTier].intValue
                venueDeal.timeLimit = deal[Constants.dealExpires].intValue
                venueDeal.value = deal[Constants.dealValue].floatValue
                venueDeal.venue = venue
                var venueId = "\(venue.identifier).\(venueDeal.tier)"
                venueDeal.id = venueId
                // check for current object
                let realm = Realm()
                // Query using a predicate string
                var dealPreviouslyDisplayed = realm.objectForPrimaryKey(VenueDeal.self, key: venueId)
                if (dealPreviouslyDisplayed != nil) {
                    //println("This is a previously pulled deal, checking dates")
                    // we need to check the date
                    let expiresTime = dealPreviouslyDisplayed?.expirationDate
                    // see how much time has lapsed
                    var compareDates: NSComparisonResult = NSDate().compare(expiresTime!)
                    if compareDates == NSComparisonResult.OrderedAscending {
                        // the deal has not expired yet
                        //  println("This deal is still good")
                    } else {
                        //the deal has expired
                        // println("This deal has expired")
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
                    println(time)
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