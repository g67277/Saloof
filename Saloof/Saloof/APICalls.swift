//
//  APICalls.swift
//  Saloof
//
//
//  Created by Nazir Shuqair on 8/7/15.
//  Copyright (c) 2015 SNASTek. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

public class APICalls {
    
    let prefs: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    
    func getMyRestaurant(token: NSString) ->(Bool){
        
        if Reachability.isConnectedToNetwork(){
            
            
            var url:NSURL = NSURL(string: "http://ec2-52-2-195-214.compute-1.amazonaws.com/api/Venue/MyVenue")!
            
            var request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "GET"
            request.timeoutInterval = 60
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            var reponseError: NSError?
            var response: NSURLResponse?
            
            var urlData: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError)
            
            if ( urlData != nil ) {
                let res = response as! NSHTTPURLResponse!;
                
                NSLog("Response code: %ld", res.statusCode);
                
                if (res.statusCode >= 200 && res.statusCode < 300){
                    
                    var responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                    
                    var error: NSError?
                    
                    let json = JSON(data: urlData!)
                    
                    if(json["Id"] != nil){
                        
                        debugPrint("Data Recieved")
                        var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                        prefs.setObject(json["Id"].string, forKey: "restID")
                        prefs.synchronize()
                        DataSaving.saveRestaurantProfile(json)
                        return true
                        
                    } else {
                        var error_msg:NSString
                        if json["error_message"] != nil {
                            error_msg = json["error_message"].string!
                            debugPrint("error response")
                        } else {
                            error_msg = "Unknown Error"
                            debugPrint("Unknown Error")
                        }
                        
                        var alertView:UIAlertView = UIAlertView()
                        alertView.title = "Sign in Failed!"
                        alertView.message = error_msg as String
                        alertView.delegate = self
                        alertView.addButtonWithTitle("OK")
                        alertView.show()
                        //
                    }
                    
                }
            }else {
                var alertView:UIAlertView = UIAlertView()
                alertView.title = "Sign in Failed!"
                alertView.message = "Connection Failure"
                if let error = reponseError {
                    alertView.message = (error.localizedDescription)
                }
                alertView.delegate = self
                alertView.addButtonWithTitle("OK")
                alertView.show()
            }
            
        }else{
            var alertView:UIAlertView = UIAlertView()
            alertView.title = "No network"
            alertView.message = "Please make sure you are connected then try again"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        }
        
        
        
        return false
    }
    
    func uploadDeal(call: NSString, token: String) -> (Bool){
        
        if Reachability.isConnectedToNetwork(){
            
            var url:NSURL = NSURL(string: "http://ec2-52-2-195-214.compute-1.amazonaws.com/api/Deal")!
            
            var postData:NSData = call.dataUsingEncoding(NSASCIIStringEncoding)!
            
            var postLength:NSString = String( call.length)
            
            var request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.HTTPBody = postData
            request.timeoutInterval = 60
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            var reponseError: NSError?
            var response: NSURLResponse?
            
            var urlData: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError)
            
            if ( urlData != nil ) {
                let res = response as! NSHTTPURLResponse!;
                
                NSLog("Response code: %ld", res.statusCode);
                println(res.debugDescription)
                
                if (res.statusCode >= 200 && res.statusCode < 300){
                    
                    return true
                    
                }else {
                    
                    var error: NSError?
                    let jsonData:NSDictionary = NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers , error: &error) as! NSDictionary
                    
                    var alertView:UIAlertView = UIAlertView()
                    alertView.title = "Sign in Failed!"
                    alertView.message = jsonData["error_description"] as? String
                    alertView.delegate = self
                    alertView.addButtonWithTitle("OK")
                    alertView.show()
                    debugPrint("another error")
                    return false
                }
            }else{
                var alertView:UIAlertView = UIAlertView()
                alertView.title = "Sign in Failed!"
                alertView.message = "Connection Failure"
                if let error = reponseError {
                    alertView.message = (error.localizedDescription)
                }
                alertView.delegate = self
                alertView.addButtonWithTitle("OK")
                alertView.show()
                return false
            }
        }else{
            var alertView:UIAlertView = UIAlertView()
            alertView.title = "No network"
            alertView.message = "Please make sure you are connected then try again"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        }
        return false
        
    }
    
    func getBalance(id: String, token: NSString) ->(JSON){
        
        //var callString = "http://ec2-52-2-195-214.compute-1.amazonaws.com/api/Venue/BalanceSummary?id=\(id)"
        var callString = "http://ec2-52-2-195-214.compute-1.amazonaws.com/api/Venue/BalanceSummary?id=CB29A448-84C9-4630-A0B0-06497A613DA6"
        var url:NSURL = NSURL(string: callString)!
        
        var request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.timeoutInterval = 60
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        var reponseError: NSError?
        var response: NSURLResponse?
        
        var urlData: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError)
        
        if ( urlData != nil ) {
            let res = response as! NSHTTPURLResponse!;
            
            NSLog("Response code: %ld", res.statusCode);
            
            if (res.statusCode >= 200 && res.statusCode < 300){
                
                var responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                
                var error: NSError?
                
                let json = JSON(data: urlData!)
                
                if(json["VenueId"] != nil){
                    
                    debugPrint("Data Recieved")
                    return json
                    
                } else {
                    var error_msg:NSString
                    if json["error_message"] != nil {
                        error_msg = json["error_message"].string!
                        debugPrint("error response")
                    } else {
                        error_msg = "Unknown Error"
                        debugPrint("Unknown Error")
                    }
                }
            }
        }else {
            if let error = reponseError {
                println(error.localizedDescription)
            }
        }
        return nil
    }
    
    class func getLocalVenues(token: NSString, location: NSString) ->(Bool){
        NSLog("Pulling local venues");
        if Reachability.isConnectedToNetwork(){
            var url:NSURL = NSURL(string: "http://ec2-52-2-195-214.compute-1.amazonaws.com/api/Venue/GetLocal?lat=38.907192&lng=-77.036871")!
            
            var request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "GET"
            request.timeoutInterval = 60
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            var reponseError: NSError?
            var response: NSURLResponse?
            
            var urlData: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError)
            let JSONObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(urlData!, options: nil, error: nil)
            
            if let returnedObjects = JSONObject as? [AnyObject] {
                for venue in returnedObjects {
                    //println(venue)
                    let venueJson = JSON(venue)
                    // Parse the JSON file using SwiftlyJSON
                    APICalls.parseJSONVenues(venueJson)
                }
                return true
                
            }else {
                println("There are no Saloof venues near this user")
                return false
            }
        } else {
            var alertView:UIAlertView = UIAlertView()
            alertView.title = "No network"
            alertView.message = "Please make sure you are connected then try again"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        }
        return false
    }
    
    class func getLocalDeals(token: NSString, location: NSString) ->(Bool){
        NSLog("Pulling local venues");
        if Reachability.isConnectedToNetwork(){
            var url:NSURL = NSURL(string: "http://ec2-52-2-195-214.compute-1.amazonaws.com/api/Venue/GetLocal?lat=38.907192&lng=-77.036871")!
            
            var request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "GET"
            request.timeoutInterval = 60
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            var reponseError: NSError?
            var response: NSURLResponse?
            
            var urlData: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError)
            let JSONObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(urlData!, options: nil, error: nil)
            
            if let returnedVenues = JSONObject as? [AnyObject] {
                for venue in returnedVenues {
                    let venueJson = JSON(venue)
                    // Parse the JSON file using SwiftlyJSON
                    APICalls.parseJSONDeals(venueJson)
                }
                return true
                
            }else {
                println("There are no Saloof deals near this user")
                return false
            }
        } else {
            var alertView:UIAlertView = UIAlertView()
            alertView.title = "No network"
            alertView.message = "Please make sure you are connected then try again"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        }
        return false
    }
    
    class func parseJSONVenues(json: JSON) {
        let venue = Venue()
        // get venue information information
        venue.identifier = json["Id"].stringValue
        venue.phone = json["phone"].stringValue
        venue.name = json["name"].stringValue
        venue.webUrl = json["url"].stringValue
        // address
        let street = json["location"]["address"].stringValue
        let city = json["location"]["city"].stringValue
        let state = json["location"]["state"].stringValue
        let zip = json["location"]["postalcode"].stringValue
        venue.address = "\(street) \n \(city), \(state)  \(zip)"
        
        
        let imageUrlString = json["defaultPicUrl"].stringValue
        venue.hours = json["status"].stringValue
        venue.priceTier = json["priceTier"].intValue
        venue.sourceType = Constants.sourceTypeSaloof
        venue.favorites = json["favourites"].intValue
        venue.likes = json["likes"].intValue
        // get the default deal
        let isActive = json["deals"][0]["active"].boolValue
        if isActive {
            venue.defaultDealID = json["deals"][0]["id"].stringValue
            venue.defaultDealTitle = json["deals"][0]["title"].stringValue
            venue.defaultDealDesc = json["deals"][0]["description"].stringValue
            venue.defaultDealValue = json["deals"][0]["deal_value"].floatValue
        }
        
        let imageUrl = NSURL(string: imageUrlString)
        if let data = NSData(contentsOfURL: imageUrl!){
            venue.hasImage = true
            let venueImage = UIImage(data: data)
            venue.image = venueImage
        }
        let realm = Realm()
        realm.write {
            //realm.add(venue)
            realm.create(Venue.self, value: venue, update: true)
            
        }
    }
    
    class func parseJSONDeals(json: JSON) {
        let venue = Venue()
        // get venue information information
        venue.identifier = json["Id"].stringValue
        venue.phone = json["phone"].stringValue
        venue.name = json["name"].stringValue
        venue.webUrl = json["url"].stringValue
        // address
        let street = json["location"]["address"].stringValue
        let city = json["location"]["city"].stringValue
        let state = json["location"]["state"].stringValue
        let zip = json["location"]["postalcode"].stringValue
        venue.address = "\(street) \n \(city), \(state)  \(zip)"
        
        
        let imageUrlString = json["defaultPicUrl"].stringValue
        venue.hours = json["status"].stringValue
        venue.priceTier = json["priceTier"].intValue
        venue.sourceType = Constants.sourceTypeSaloof
        venue.favorites = json["likes"].intValue
        venue.likes = json["favourites"].intValue
        
        let imageUrl = NSURL(string: imageUrlString)
        if let data = NSData(contentsOfURL: imageUrl!){
            venue.hasImage = true
            let venueImage = UIImage(data: data)
            venue.image = venueImage
        }
        venue.swipeValue = 3   // deal only
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
                    venueDeal.venue = venue
                    venueDeal.restId = venue.identifier
                    // check for current object
                    let realm = Realm()
                    // Query using a predicate string
                    var dealPreviouslyDisplayed = realm.objectForPrimaryKey(VenueDeal.self, key: venueDeal.id)
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
    
}