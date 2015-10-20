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
    
    class func getMyRestaurant(token: NSString, completion: Bool -> ()){
        
        let url:NSURL = NSURL(string: "http://ec2-52-2-195-214.compute-1.amazonaws.com/api/Venue/MyVenue")!
        
        let request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.timeoutInterval = 60
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let reponseError: NSError?
        let queue:NSOperationQueue = NSOperationQueue()
            
            NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse?, urlData: NSData?, error: NSError?) -> Void in
                /* Your code */
                let res = response as! NSHTTPURLResponse!
                if res != nil{
                print(res.statusCode)
                if res.statusCode >= 200 && res.statusCode < 300 {
                    
                    let json = JSON(data: urlData!)
                    
                    if(json["Id"] != nil){
                        
                        debugPrint("Data Recieved")
                        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                        prefs.setObject(json["Id"].string, forKey: "restID")
                        prefs.synchronize()
                        DataSaving.saveRestaurantProfile(json)
                        
                        completion(true)
                    } else {
                        var error_msg:NSString
                        if json["error_message"] != nil {
                            error_msg = json["error_message"].string!
                            debugPrint("error response")
                        } else {
                            error_msg = "Unknown Error"
                            debugPrint("Unknown Error")
                        }
                        
                        let alertView:UIAlertView = UIAlertView()
                        alertView.title = "Sign in Failed!"
                        alertView.message = error_msg as String
                        alertView.delegate = self
                        alertView.addButtonWithTitle("OK")
                        alertView.show()
                        completion(false)
                    }
                }else {
                    let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                    if prefs.stringForKey("TOKEN") == nil || prefs.stringForKey("TOKEN") == ""{
                        dispatch_async(dispatch_get_main_queue()){
                            let alertView:UIAlertView = UIAlertView()
                            alertView.title = "Sign in Failed!"
                            alertView.message = "Connection Failure"
                            if let error = reponseError {
                                alertView.message = (error.localizedDescription)
                            }
                            alertView.delegate = self
                            alertView.addButtonWithTitle("OK")
                            alertView.show()
                        }
                    }
                    completion(false)
                }
                }else{
                    dispatch_async(dispatch_get_main_queue()) {
                        let alertView:UIAlertView = UIAlertView()
                        alertView.title = "Our bad"
                        alertView.message = "Looks like we are updating the server, please try again later"
                        alertView.delegate = self
                        alertView.addButtonWithTitle("OK")
                        alertView.show()
                    }
                    completion(false)
                }
            })
    }
    
    func uploadDeal(call: NSString, token: String){
        
        let url:NSURL = NSURL(string: "http://ec2-52-2-195-214.compute-1.amazonaws.com/api/Deal")!
        
        let postData:NSData = call.dataUsingEncoding(NSASCIIStringEncoding)!
        
        let postLength:NSString = String( call.length)
        
        let request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.HTTPBody = postData
        request.timeoutInterval = 60
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        
        let queue:NSOperationQueue = NSOperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse?, urlData: NSData?, error: NSError?) -> Void in
            let res = response as! NSHTTPURLResponse!
            if res != nil{
                print(res.statusCode)
                if res.statusCode >= 200 && res.statusCode < 300{
                    print("Deal uploaded")
                } else {
                    
                    //var error: NSError?
                    //let jsonData:NSDictionary = NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers , error: &error) as! NSDictionary
                    //print(jsonData["error_description"] as? String)
                }
            }
        })
        
    }

    func getBalance(id: String, token: String, completion: JSON -> ()){
        
        let callString = "http://ec2-52-2-195-214.compute-1.amazonaws.com/api/Venue/BalanceSummary?id=\(id)"
        let url:NSURL = NSURL(string: callString)!
        
        let request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.timeoutInterval = 60
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        
        let queue:NSOperationQueue = NSOperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse?, urlData: NSData?, error: NSError?) -> Void in
            /* Your code */
            let res = response as! NSHTTPURLResponse!
            if res != nil{
                print(res.statusCode)
                if res.statusCode >= 200 && res.statusCode < 300{
                    let json = JSON(data: urlData!)
                    if json != nil{
                        print("business home data recived")
                        completion(json)
                    }
                }
            }
        })
        
    }
    
    
    func uploadImg(jpgImg: NSData, imgName: String, completion: Bool -> ()){
        
        let url = "http://ec2-52-2-195-214.compute-1.amazonaws.com/api/Image"
        print("Size of image to be uploaded: \(jpgImg.length)")
        
        sendFile(url, fileName: imgName, data: jpgImg, completionHandler: { (response: NSURLResponse!, urlData: NSData!, error: NSError!) -> Void in
            
            let res = response as! NSHTTPURLResponse!
            
            print("uploaded")
            print(res.statusCode)
            if res.statusCode == 200{
                completion(true)
            }else{
                let json = JSON(data: urlData!)
                print(json["error_message"])
                completion(false)
            }
        })
    }
    
    class func uploadBalance(credits: Double, restID: String, token: String){
        
            let call = "http://ec2-52-2-195-214.compute-1.amazonaws.com/api/Venue/AddCredit?venueId=\(restID)&credit=\(Int(credits))"
            //var call = "http://ec2-52-2-195-214.compute-1.amazonaws.com/api/Venue/AddCredit?venueId=B1287897-C687-4724-8A21-9BFA7023A881&credit=5"
            print(call)
            let url:NSURL = NSURL(string: call)!
            
        
        let request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.timeoutInterval = 60
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
            let queue:NSOperationQueue = NSOperationQueue()
            
            NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse?, urlData: NSData?, error: NSError?) -> Void in
                /* Your code */
                let res = response as! NSHTTPURLResponse!
                if res != nil{
                    print(res.statusCode)
                    if res.statusCode >= 200 && res.statusCode < 300{
                        print("Credits uploaded")
                    } else {
                        print("Unable to upload credits")
                        //var error: NSError?
                        //let jsonData:NSDictionary = NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers , error: &error) as! NSDictionary
                    }
                }
            })
    }
    
    
    class func getLocalVenues(token: NSString, venueParameters: NSString, completion: Bool -> ()){
        
        let url:NSURL = NSURL(string: "http://ec2-52-2-195-214.compute-1.amazonaws.com/api/\(venueParameters)")!
        //var url:NSURL = NSURL(string: "http://ec2-52-2-195-214.compute-1.amazonaws.com/api/venue/GetVenuesByPriceNLocation?priceTier=0&\(venueParameters)")!
        //println("Getting Venues URL: \(url)")
        let request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.timeoutInterval = 60
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        //var reponseError: NSError?
        //var response: NSURLResponse?
        let queue:NSOperationQueue = NSOperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse?, urlData: NSData?, error: NSError?) -> Void in
            let res = response as! NSHTTPURLResponse!
            if res != nil {
                print(res.statusCode)
                if res.statusCode >= 200 && res.statusCode < 300 {
                    do {
                        let JSONObject: AnyObject? = try NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers ) as! NSDictionary
                        // use jsonData
                        if let returnedVenues = JSONObject as? [AnyObject] {
                            print("Saloof returned \(returnedVenues.count) venues")
                            
                            for venue in returnedVenues {
                                let venueJson = JSON(venue)
                                APICalls.parseJSONVenues(venueJson)
                            }
                            completion (true)
                        }

                    } catch {
                        // report error
                         completion (false)
                    }
                    //let JSONObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(urlData!, options: [])
                    /*
                    if let returnedVenues = JSONObject as? [AnyObject] {
                        print("Saloof returned \(returnedVenues.count) venues")
                    
                        for venue in returnedVenues {
                            let venueJson = JSON(venue)
                            APICalls.parseJSONVenues(venueJson)
                        }
                        completion (true)
                    }*/
                } else {
                    completion (false)
                }
            } else {
                completion (false)
            }
        })
    }
    
    
    class func getSaloofDeals(token: NSString, venueParameters: NSString, completion: Bool -> ()){
        
        let url:NSURL = NSURL(string: "http://ec2-52-2-195-214.compute-1.amazonaws.com/api/\(venueParameters)")!
        //var url:NSURL = NSURL(string: "http://ec2-52-2-195-214.compute-1.amazonaws.com/api/venue/GetVenuesByPriceNLocation?priceTier=0&\(venueParameters)")!
        let request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.timeoutInterval = 60
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        //var reponseError: NSError?
        //var response: NSURLResponse?
        let queue:NSOperationQueue = NSOperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse?, urlData: NSData?, error: NSError?) -> Void in
            let res = response as! NSHTTPURLResponse!
            if res != nil {
                print(res.statusCode)
                if res.statusCode >= 200 && res.statusCode < 300 {
                    do {
                        let JSONObject: AnyObject? = try NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers ) as! NSDictionary
                        // use jsonData
                        if let returnedVenues = JSONObject as? [AnyObject] {
                            for venue in returnedVenues {
                                let venueJson = JSON(venue)
                                // Parse the JSON file using SwiftlyJSON
                                APICalls.parseJSONDeals(venueJson)
                            }
                            completion (true)
                        }
                    } catch {
                        // report error
                        completion (false)
                    }

                   // let JSONObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(urlData!, options: nil, error: nil)
                    /*
                    if let returnedVenues = JSONObject as? [AnyObject] {
                        for venue in returnedVenues {
                            let venueJson = JSON(venue)
                            // Parse the JSON file using SwiftlyJSON
                            APICalls.parseJSONDeals(venueJson)
                        }
                        completion (true)
                    }*/
                } else {
                    completion (false)
                }
            } else {
                completion (false)
            }
        })
    }
    class func  updateLikeCountForVenue (venue: String, didLike: Bool, completion: Bool -> ()) {
        
    //http://ec2-52-2-195-214.compute-1.amazonaws.com/api/Venue/Like?id=CB29A448-84C9-4630-A0B0-06497A613DA6&like=true
        let didLikeString = (didLike) ? "true" : "false"
        let baseUrlString = "http://ec2-52-2-195-214.compute-1.amazonaws.com/api/Venue/Like?id=\(venue)&like=\(didLikeString)"
        print(baseUrlString)
        let url:NSURL = NSURL(string: baseUrlString)!
        let request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.timeoutInterval = 60
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let queue:NSOperationQueue = NSOperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse?, urlData: NSData?, error: NSError?) -> Void in
            let res = response as! NSHTTPURLResponse!
            if res != nil {
                print(res.statusCode)
                if res.statusCode >= 200 && res.statusCode < 300 {
                    let testString = (didLike) ? "increased" : "decreased"
                    print("\(testString) this venue's like count")
                    completion (true)
                } else {
                    print("unable to like venue")
                    completion (false)
                }
            } else {
              completion (false)
            }
            
        })
    }
    
    class func  updateFavoriteCountForVenue (venue: String, didFav: Bool, completion: Bool -> ()) {
        
        //http://ec2-52-2-195-214.compute-1.amazonaws.com/api/Venue/Favourite?id=CB29A448-84C9-4630-A0B0-06497A613DA6&favourite=true
        let didFavString = (didFav) ? "true" : "false"
        let baseUrlString = "http://ec2-52-2-195-214.compute-1.amazonaws.com/api/Venue/Favourite?id=\(venue)&favourite=\(didFavString)"
        print(baseUrlString)
        let url:NSURL = NSURL(string: baseUrlString)!
        let request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.timeoutInterval = 60
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let queue:NSOperationQueue = NSOperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse?, urlData: NSData?, error: NSError?) -> Void in
            let res = response as! NSHTTPURLResponse!
            if res != nil {
                //println("Retrieved status code for favoriting")
                //println("Favorited item: status code: \(res.statusCode)")
                if res.statusCode >= 200 && res.statusCode < 300 {
                    completion (true)
                } else {
                    //println("unable to favorite venue")
                    completion (false)
                }
            } else {
                 completion (false)
            }
        })
    }

    
    class func shouldDecrementCreditForDeal (deal: String, token: String, completion: Bool -> ()) {
        
        //http://ec2-52-2-195-214.compute-1.amazonaws.com/api/Deal/Purchase?dealId=E1D72619-C35E-4F47-949A-0227AF1957B8
        let baseUrlString = "http://ec2-52-2-195-214.compute-1.amazonaws.com/api/Deal/Purchase?dealId=\(deal)"
        print(baseUrlString)
        let url:NSURL = NSURL(string: baseUrlString)!
        let request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 60
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let queue:NSOperationQueue = NSOperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse?, urlData: NSData?, error: NSError?) -> Void in
            let res = response as! NSHTTPURLResponse!
            if res != nil {
                print(res.statusCode)
                if res.statusCode >= 200 && res.statusCode < 300 {
                    debugPrint("Deal purchase successful")
                    completion (true)
                } else {
                    debugPrint("unable to purchase deal")
                    completion (false)
                }
            } else {
                completion (false)
                debugPrint("No response")
            }
            
        })
    }
    
    
    class func shouldSwapCreditForDeal (originalDeal: String, token: String, newDeal:String, completion: Bool -> ()) {
        
        //http://ec2-52-2-195-214.compute-1.amazonaws.com/api/Deal/Swap?originalDealId=E1D72619-C35E-4F47-949A-0227AF1957B8&newDealId=0F2A43BF-B902-4243-BB67-188B3F9EDE05
        let baseUrlString = "http://ec2-52-2-195-214.compute-1.amazonaws.com/api/Deal/Swap?originalDealId=\(originalDeal)&newDealId=\(newDeal)"
        print(baseUrlString)
        let url:NSURL = NSURL(string: baseUrlString)!
        let request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 60
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let queue:NSOperationQueue = NSOperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse?, urlData: NSData?, error: NSError?) -> Void in
            let res = response as! NSHTTPURLResponse!
            if res != nil {
                //println(res.statusCode)
                if res.statusCode >= 200 && res.statusCode < 300 {
                    debugPrint("Deals swap successful")
                    completion (true)
                } else {
                    debugPrint("unable to swap deals")
                    completion (false)
                }
            } else {
                completion (false)
                 debugPrint("No response")
            }
            
        })
    }
    
    class func shouldFetchFoursquareLocations(foursquareURl: NSString, completion: Bool -> ()){
        let apiUrl = "https://api.foursquare.com/v2/venues/explore?&client_id=KNSDVZA1UWUPSYC1QDCHHTLD3UG5HDMBR5JA31L3PHGFYSA0&client_secret=U40WCCSESYMKAI4UYAWGK2FMVE3CBMS0FTON0KODNPEY0LBR&openNow=1&v=20150101&venuePhotos=1&limit=10\(foursquareURl)"
        let url:NSURL = NSURL(string: apiUrl as String)!
        let request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        //var reponseError: NSError?
       // var response: NSURLResponse?
        let queue:NSOperationQueue = NSOperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse?, urlData: NSData?, error: NSError?) -> Void in
            
            if  let response = NSData(contentsOfURL: url) {
                do {
                    let JSONObject: AnyObject? = try (NSJSONSerialization.JSONObjectWithData(response, options:NSJSONReadingOptions(rawValue: 0)) as! NSDictionary)["response"]
                    // use jsonData
                    if let object: AnyObject = JSONObject {
                        // haveItems = true
                        var groups = object["groups"] as! [AnyObject]
                        //  get array of items
                        let venues = groups[0]["items"] as! [AnyObject]
                        for item in venues {
                            // get the venue
                            if let venue = item["venue"] as? [String: AnyObject] {
                                //println(venue)
                                let venueJson = JSON(venue)
                                // Parse the JSON file using SwiftlyJSON
                                //parseJSON(venueJson, source: Constants.sourceTypeFoursquare)
                                self.parseFoursquareJSON(venueJson, source: Constants.sourceTypeFoursquare)
                            }
                        }
                        print("Foursquare returned \(venues.count) venues")
                        completion(true)
                    }
                } catch {
                    // report error
                    completion (false)
                }
                /*
                let json: AnyObject? = (NSJSONSerialization.JSONObjectWithData(response, options: NSJSONReadingOptions(0), error: nil) as! NSDictionary)["response"]
                if let object: AnyObject = json {
                    // haveItems = true
                    var groups = object["groups"] as! [AnyObject]
                    //  get array of items
                    var venues = groups[0]["items"] as! [AnyObject]
                    for item in venues {
                        // get the venue
                        if let venue = item["venue"] as? [String: AnyObject] {
                            //println(venue)
                            let venueJson = JSON(venue)
                            // Parse the JSON file using SwiftlyJSON
                            //parseJSON(venueJson, source: Constants.sourceTypeFoursquare)
                            self.parseFoursquareJSON(venueJson, source: Constants.sourceTypeFoursquare)
                        }
                    }
                    print("Foursquare returned \(venues.count) venues")
                    completion(true)
                }*/
                //offsetCount = offsetCount + 10
            } else {
                completion (false)
            }
            
        })
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
        let distanceInMeters = json["dist_to_location"].floatValue
        var distanceInMiles = distanceInMeters / 1609.344
        // make sure it is greater than 0
        distanceInMiles = (distanceInMiles > 0) ? distanceInMiles : 0
        let formattedDistance : String = String(format: "%.01f", distanceInMiles)
        venue.distance = formattedDistance
        
        let imageUrlString = json["defaultPicUrl"].stringValue
        venue.hours = json["status"].stringValue
        venue.priceTier = json["priceTier"].intValue
        venue.sourceType = Constants.sourceTypeSaloof
        venue.favorites = json["favourites"].intValue
        venue.likes = json["likes"].intValue
        venue.swipeValue = 0
        // get the default deal
        let isActive = json["deals"][0]["active"].boolValue
        if isActive {
            venue.defaultDealID = json["deals"][0]["id"].stringValue
            venue.defaultDealTitle = json["deals"][0]["title"].stringValue
            venue.defaultDealDesc = json["deals"][0]["description"].stringValue
            venue.defaultDealValue = json["deals"][0]["deal_value"].floatValue
        }
        let formattedImageUrl = "http://ec2-52-2-195-214.compute-1.amazonaws.com/Images/\(imageUrlString).jpg"
        //http://ec2-52-2-195-214.compute-1.amazonaws.com/Images/nYmm3rydT6pgwlY.jpg
        venue.imageUrl = formattedImageUrl
        let realm = try!  Realm()
        realm.write {
            //realm.add(venue)
            realm.create(Venue.self, value: venue, update: true)
            
        }
    }
    class  func parseFoursquareJSON(json: JSON, source: String) {
        let venue = Venue()
        venue.identifier = json["id"].stringValue
        venue.phone = json["contact"]["formattedPhone"].stringValue
        venue.name = json["name"].stringValue
        venue.webUrl = json["url"].stringValue
        let imagePrefix = json["photos"]["groups"][0]["items"][0]["prefix"].stringValue
        let imageSuffix = json["photos"]["groups"][0]["items"][0]["suffix"].stringValue
        let imageName = imagePrefix + "400x400" +  imageSuffix
        // Address
        venue.imageUrl = imagePrefix + "400x400" +  imageSuffix
        let locationStreet = json["location"]["address"].stringValue
        let locationCity = json["location"]["city"].stringValue
        let locationState = json["location"]["state"].stringValue
        let locationZip = json["location"]["postalCode"].stringValue
        let address = locationStreet + "\n" + locationCity + ", " + locationState + "  " + locationZip
        venue.address = address
        venue.hours = json["hours"]["status"].stringValue
        let distanceInMeters = json["location"]["distance"].floatValue
        var distanceInMiles = distanceInMeters / 1609.344
        // make sure it is greater than 0
        distanceInMiles = (distanceInMiles > 0) ? distanceInMiles : 0
        let formattedDistance : String = String(format: "%.01f", distanceInMiles)
        venue.distance = formattedDistance
        venue.priceTier = json["price"]["tier"].intValue
        //println("Price tier: \(venue.priceTier)")
        venue.sourceType = source
        venue.swipeValue = 0
        if source == Constants.sourceTypeSaloof {
            // get the default deal
            venue.defaultDealTitle = json["deals"]["deal"][0]["title"].stringValue
            venue.defaultDealDesc = json["deals"]["deal"][0]["description"].stringValue
            venue.defaultDealValue = json["deals"]["deal"][0]["value"].floatValue
            venue.favorites = json[Constants.restStats][Constants.restFavorites].intValue
            venue.likes = json[Constants.restStats][Constants.restLikes].intValue
        }
        let imageUrl = NSURL(string: imageName)
        if let data = NSData(contentsOfURL: imageUrl!){
            
            let venueImage = UIImage(data: data)
            venue.image = venueImage
            venue.hasImage = true
        }
        let realm = try! Realm()
        realm.write {
            realm.create(Venue.self, value: venue, update: true)
        }
       // venueList.append(venue)
    }
    
    class func parseJSONDeals(json: JSON) {
        
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
                    let formattedImageUrl = "http://ec2-52-2-195-214.compute-1.amazonaws.com/Images/\(imageUrlString).jpg"
                    venueDeal.venueImageUrl = formattedImageUrl
                    // check for current object
                    let realm = try! Realm()
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
    
    func sendFile(
        urlPath:String,
        fileName:String,
        data:NSData,
        completionHandler: (NSURLResponse!, NSData!, NSError!) -> Void){
            
            var url: NSURL = NSURL(string: urlPath)!
            var request1: NSMutableURLRequest = NSMutableURLRequest(URL: url)
            
            request1.HTTPMethod = "POST"
            
            
            let boundary = generateBoundaryString()
            let fullData = photoDataToFormData(data,boundary:boundary,fileName:fileName)
            
            request1.setValue("multipart/form-data; boundary=" + boundary,
                forHTTPHeaderField: "Content-Type")
            request1.setValue(fileName, forHTTPHeaderField: "ImageId")
            
            
            // REQUIRED!
            request1.setValue(String(fullData.length), forHTTPHeaderField: "Content-Length")
            
            request1.HTTPBody = fullData
            request1.HTTPShouldHandleCookies = false
            
            let queue:NSOperationQueue = NSOperationQueue()
            
            NSURLConnection.sendAsynchronousRequest(
                request1,
                queue: queue,
                completionHandler:completionHandler)
    }
    
    // this is a very verbose version of that function
    // you can shorten it, but i left it as-is for clarity
    // and as an example
    func photoDataToFormData(data:NSData,boundary:String,fileName:String) -> NSData {
        let fullData = NSMutableData()
        
        // 1 - Boundary should start with --
        let lineOne = "--" + boundary + "\r\n"
        fullData.appendData(lineOne.dataUsingEncoding(
            NSUTF8StringEncoding,
            allowLossyConversion: false)!)
        
        // 2
        let lineTwo = "Content-Disposition: form-data; name=\"image\"; filename=\"" + fileName + ".jpg\"\r\n"
        NSLog(lineTwo)
        fullData.appendData(lineTwo.dataUsingEncoding(
            NSUTF8StringEncoding,
            allowLossyConversion: false)!)
        
        // 3
        let lineThree = "Content-Type: image/jpg\r\n\r\n"
        fullData.appendData(lineThree.dataUsingEncoding(
            NSUTF8StringEncoding,
            allowLossyConversion: false)!)
        
        // 4
        fullData.appendData(data)
        
        // 5
        let lineFive = "\r\n"
        fullData.appendData(lineFive.dataUsingEncoding(
            NSUTF8StringEncoding,
            allowLossyConversion: false)!)
        
        // 6 - The end. Notice -- at the start and at the end
        let lineSix = "--" + boundary + "--\r\n"
        fullData.appendData(lineSix.dataUsingEncoding(
            NSUTF8StringEncoding,
            allowLossyConversion: false)!)
        
        return fullData
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().UUIDString)"
        //return "------WebKitFormBoundaryghAVpvGCFLS36e1D"
    }
    
}