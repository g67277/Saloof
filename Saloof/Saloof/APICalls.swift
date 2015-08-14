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
        
        var url:NSURL = NSURL(string: "http://ec2-52-2-195-214.compute-1.amazonaws.com/api/Venue/MyVenue")!
        
        var request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.timeoutInterval = 60
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        var reponseError: NSError?
        var response: NSURLResponse?
        let queue:NSOperationQueue = NSOperationQueue()
            
            NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse!, urlData: NSData!, error: NSError!) -> Void in
                /* Your code */
                let res = response as! NSHTTPURLResponse!
                if res != nil{
                println(res.statusCode)
                if res.statusCode >= 200 && res.statusCode < 300{
                    var error: NSError?
                    
                    let json = JSON(data: urlData!)
                    
                    if(json["Id"] != nil){
                        
                        debugPrint("Data Recieved")
                        var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
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
                        
                        var alertView:UIAlertView = UIAlertView()
                        alertView.title = "Sign in Failed!"
                        alertView.message = error_msg as String
                        alertView.delegate = self
                        alertView.addButtonWithTitle("OK")
                        alertView.show()
                        completion(false)
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
                    completion(false)
                }
                }else{
                    dispatch_async(dispatch_get_main_queue()) {
                        var alertView:UIAlertView = UIAlertView()
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
        
        let queue:NSOperationQueue = NSOperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse!, urlData: NSData!, error: NSError!) -> Void in
            /* Your code */
            let res = response as! NSHTTPURLResponse!
            if res != nil{
                println(res.statusCode)
                if res.statusCode >= 200 && res.statusCode < 300{
                    println("Deal uploaded")
                }else{
                    var error: NSError?
                    let jsonData:NSDictionary = NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers , error: &error) as! NSDictionary
                    println(jsonData["error_description"] as? String)
                }
            }
        })
        
    }

    func getBalance(id: String, token: String, completion: JSON -> ()){
        
        var callString = "http://ec2-52-2-195-214.compute-1.amazonaws.com/api/Venue/BalanceSummary?id=\(id)"
        var url:NSURL = NSURL(string: callString)!
        
        var request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.timeoutInterval = 60
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        var reponseError: NSError?
        var response: NSURLResponse?
        let queue:NSOperationQueue = NSOperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse!, urlData: NSData!, error: NSError!) -> Void in
            /* Your code */
            let res = response as! NSHTTPURLResponse!
            if res != nil{
                println(res.statusCode)
                if res.statusCode >= 200 && res.statusCode < 300{
                    let json = JSON(data: urlData!)
                    if json != nil{
                        println("business home data recived")
                        completion(json)
                    }
                }
            }
        })
        
    }
    
    func uploadImg(imgData: UIImage, imgName: String, completion: Bool -> ()){
        
        let url = "http://ec2-52-2-195-214.compute-1.amazonaws.com/api/Image"
        let data: NSData = UIImageJPEGRepresentation(imgData, 1)
        println(data.length)
        
        sendFile(url, fileName: imgName, data: data, completionHandler: { (response: NSURLResponse!, urlData: NSData!, error: NSError!) -> Void in
            
            let res = response as! NSHTTPURLResponse!
            
            println("uploaded")
            println(res.statusCode)
            if res.statusCode == 200{
                completion(true)
            }else{
                let json = JSON(data: urlData!)
                println(json["error_message"])
                completion(false)
            }
        })
    }
    
    class func uploadBalance(credits: Double, restID: String, token: String){
        
            var call = "http://ec2-52-2-195-214.compute-1.amazonaws.com/api/Venue/AddCredit?venueId=\(restID)&credit=\(Int(credits))"
            //var call = "http://ec2-52-2-195-214.compute-1.amazonaws.com/api/Venue/AddCredit?venueId=B054B184-104E-431B-B007-A53130BF8005&credit=5"
            println(call)
            var url:NSURL = NSURL(string: call)!
            
            var postData:NSData = call.dataUsingEncoding(NSASCIIStringEncoding)!
            
        var request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.HTTPBody = postData
        request.timeoutInterval = 60
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        
            var reponseError: NSError?
            var response: NSURLResponse?
            let queue:NSOperationQueue = NSOperationQueue()
            
            NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse!, urlData: NSData!, error: NSError!) -> Void in
                /* Your code */
                let res = response as! NSHTTPURLResponse!
                if res != nil{
                    println(res.statusCode)
                    if res.statusCode >= 200 && res.statusCode < 300{
                        print("Credits uploaded")
                    }else{
                        var error: NSError?
                        let jsonData:NSDictionary = NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers , error: &error) as! NSDictionary
                    }
                }
            })
    }
    
    /*
    class func getLocalVenues(token: NSString, venueParameters: NSString) ->(Bool){
        NSLog("Pulling local venues");
        //var url:NSURL = NSURL(string: "http://ec2-52-2-195-214.compute-1.amazonaws.com/api/Venue/GetLocal?lat=38.907192&lng=-77.036871")!
        var url:NSURL = NSURL(string: "http://ec2-52-2-195-214.compute-1.amazonaws.com/api/\(venueParameters)")!
       // var tempPriceUrl: NSURL = NSURL(string: "http://ec2-52-2-195-214.compute-1.amazonaws.com/api/venue/GetVenuesByPriceTierNLocation?priceTier=3&lat=38.9047&lng=-77.0164")!
        /*
        Basic Locations in DC
        http://ec2-52-2-195-214.compute-1.amazonaws.com/api/Venue/GetLocal?lat=38.907192&lng=-77.036871
        Venues with location & query
        http://ec2-52-2-195-214.compute-1.amazonaws.com/api/venue/GetVenuesByCategoryNLocation?category=burger&lat=38.907192&lng=-77.036871
        Venues with price tier
        http://ec2-52-2-195-214.compute-1.amazonaws.com/api/venue/GetVenuesByPriceTierNLocation?priceTier=2&lat=38.907192&lng=-77.036871
        */
        //println("Pulling venues from Saloof")
        println("Saloof Url: \(url)")
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
            println("Saloof returned \(returnedObjects.count) venues")
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
    }*/
    
    class func getLocalVenues(token: NSString, venueParameters: NSString, completion: Bool -> ()){
        
        var url:NSURL = NSURL(string: "http://ec2-52-2-195-214.compute-1.amazonaws.com/api/\(venueParameters)")!
        var request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.timeoutInterval = 60
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        var reponseError: NSError?
        var response: NSURLResponse?
        let queue:NSOperationQueue = NSOperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse!, urlData: NSData!, error: NSError!) -> Void in
            let res = response as! NSHTTPURLResponse!
            if res != nil {
                println(res.statusCode)
                if res.statusCode >= 200 && res.statusCode < 300 {
                    let JSONObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(urlData!, options: nil, error: nil)
                    
                    if let returnedVenues = JSONObject as? [AnyObject] {
                        println("Saloof returned \(returnedVenues.count) venues")
                        for venue in returnedVenues {
                            let venueJson = JSON(venue)
                            APICalls.parseJSONVenues(venueJson)
                        }
                        completion (true)
                    }
                } else {
                    completion (false)
                }
            } else {
                completion (false)
            }
        })
    }

    class func getLocalDeals(token: NSString, location: NSString, completion: Bool -> ()){
        NSLog("Pulling local venues");
        if Reachability.isConnectedToNetwork(){
            var url:NSURL = NSURL(string: "http://ec2-52-2-195-214.compute-1.amazonaws.com/api/Venue/GetLocal?lat=39.1167&lng=-77.5500")!
            
            var request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "GET"
            request.timeoutInterval = 60
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            var reponseError: NSError?
            var response: NSURLResponse?
            let queue:NSOperationQueue = NSOperationQueue()
            
            NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse!, urlData: NSData!, error: NSError!) -> Void in
                let res = response as! NSHTTPURLResponse!
                if res != nil {
                    println(res.statusCode)
                    if res.statusCode >= 200 && res.statusCode < 300 {
                        let JSONObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(urlData!, options: nil, error: nil)
                        
                        if let returnedVenues = JSONObject as? [AnyObject] {
                            for venue in returnedVenues {
                                let venueJson = JSON(venue)
                                // Parse the JSON file using SwiftlyJSON
                                APICalls.parseJSONDeals(venueJson)
                            }
                            completion (true)
                        }
                    } else {
                        completion (false)
                    }
                } else {
                    completion (false)
                }
            })
            
        } else {
            var alertView:UIAlertView = UIAlertView()
            alertView.title = "No network"
            alertView.message = "Please make sure you are connected then try again"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        }
        completion (false)
    }

    /*
    class func getLocalDeals(token: NSString, location: NSString) ->(Bool){
        NSLog("Pulling local venues");
        if Reachability.isConnectedToNetwork(){
            var url:NSURL = NSURL(string: "http://ec2-52-2-195-214.compute-1.amazonaws.com/api/Venue/GetLocal?lat=39.1167&lng=-77.5500")!
            
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
                
            } else {
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
        return (false)
    }
    */
    
    class func  updateLikeCountForVenue (venue: String, didLike: Bool, completion: Bool -> ()) {
        
    //http://ec2-52-2-195-214.compute-1.amazonaws.com/api/Venue/Like?id=CB29A448-84C9-4630-A0B0-06497A613DA6&like=true
        var didLikeString = (didLike) ? "true" : "false"
        var baseUrlString = "http://ec2-52-2-195-214.compute-1.amazonaws.com/api/Venue/Like?id=\(venue)&like=\(didLikeString)"
        println(baseUrlString)
        var url:NSURL = NSURL(string: baseUrlString)!
        var request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.timeoutInterval = 60
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        var reponseError: NSError?
        var response: NSURLResponse?
        let queue:NSOperationQueue = NSOperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse!, urlData: NSData!, error: NSError!) -> Void in
            let res = response as! NSHTTPURLResponse!
            if res != nil {
                println(res.statusCode)
                if res.statusCode >= 200 && res.statusCode < 300 {
                    var testString = (didLike) ? "increased" : "decreased"
                    println("\(testString) this venue's like count")
                    completion (true)
                } else {
                    println("unable to like venue")
                    completion (false)
                }
            } else {
              completion (false)
            }
            
        })
    }
    
    class func  updateFavoriteCountForVenue (venue: String, didFav: Bool, completion: Bool -> ()) {
        
        //http://ec2-52-2-195-214.compute-1.amazonaws.com/api/Venue/Favourite?id=CB29A448-84C9-4630-A0B0-06497A613DA6&favourite=true
        var didFavString = (didFav) ? "true" : "false"
        var baseUrlString = "http://ec2-52-2-195-214.compute-1.amazonaws.com/api/Venue/Favourite?id=\(venue)&favourite=\(didFavString)"
        println(baseUrlString)
        var url:NSURL = NSURL(string: baseUrlString)!
        var request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.timeoutInterval = 60
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        var reponseError: NSError?
        var response: NSURLResponse?
        let queue:NSOperationQueue = NSOperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse!, urlData: NSData!, error: NSError!) -> Void in
            let res = response as! NSHTTPURLResponse!
            if res != nil {
                println("Retrieved status code for favoriting")
                println("Favorited item: status code: \(res.statusCode)")
                if res.statusCode >= 200 && res.statusCode < 300 {
                     var testString = (didFav) ? "increased" : "decreased"
                    println("\(testString) this venue's favorite count")
                    completion (true)
                } else {
                    println("unable to favorite venue")
                    completion (false)
                }
            } else {
                 completion (false)
            }
        })
    }

    
    class func shouldDecrementCreditForDeal (deal: String, token: String, completion: Bool -> ()) {
        
        //http://ec2-52-2-195-214.compute-1.amazonaws.com/api/Deal/Purchase?dealId=E1D72619-C35E-4F47-949A-0227AF1957B8
        var baseUrlString = "http://ec2-52-2-195-214.compute-1.amazonaws.com/api/Deal/Purchase?dealId=\(deal)"
        println(baseUrlString)
        var url:NSURL = NSURL(string: baseUrlString)!
        var request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 60
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        var reponseError: NSError?
        var response: NSURLResponse?
        let queue:NSOperationQueue = NSOperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse!, urlData: NSData!, error: NSError!) -> Void in
            let res = response as! NSHTTPURLResponse!
            if res != nil {
                println(res.statusCode)
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
        var baseUrlString = "http://ec2-52-2-195-214.compute-1.amazonaws.com/api/Deal/Swap?originalDealId=\(originalDeal)&newDealId=\(newDeal)"
        println(baseUrlString)
        var url:NSURL = NSURL(string: baseUrlString)!
        var request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 60
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        var reponseError: NSError?
        var response: NSURLResponse?
        let queue:NSOperationQueue = NSOperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse!, urlData: NSData!, error: NSError!) -> Void in
            let res = response as! NSHTTPURLResponse!
            if res != nil {
                println(res.statusCode)
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

    
    class func getLocalDealsByCategory(token: NSString, call: String, completion: Bool -> ()){
        
        var callString = "http://ec2-52-2-195-214.compute-1.amazonaws.com/api/venue/GetVenuesByCategoryNLocation?\(call)"
        //var callString = "http://ec2-52-2-195-214.compute-1.amazonaws.com/api/venue/GetVenuesByCategoryNLocation?category=burger&lat=39.1167&lng=-77.5500"
        var url:NSURL = NSURL(string: callString)!
        println(url)
        var request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.timeoutInterval = 60
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        var reponseError: NSError?
        var response: NSURLResponse?
        let queue:NSOperationQueue = NSOperationQueue()

        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse!, urlData: NSData!, error: NSError!) -> Void in
            /* Your code */
            let res = response as! NSHTTPURLResponse!
            if res != nil{
                println(res.statusCode)
                if res.statusCode >= 200 && res.statusCode < 300{
                    //let json = JSON(data: urlData!)
                    let JSONObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(urlData!, options: nil, error: nil)

                    if let returnedVenues = JSONObject as? [AnyObject] {
                        for venue in returnedVenues {
                            let venueJson = JSON(venue)
                            // Parse the JSON file using SwiftlyJSON
                            APICalls.parseJSONDeals(venueJson)
                        }
                        completion(true)
                    }
                }
            }
        })
    }
    
    class func getLocalDealsByPrice(token: String, call: String, completion: Bool -> ()){
        var callString = "http://ec2-52-2-195-214.compute-1.amazonaws.com/api/venue/GetVenuesByPriceTierNLocation?\(call)"
        var url:NSURL = NSURL(string: callString)!
        println(url)
        var request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.timeoutInterval = 60
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        var reponseError: NSError?
        var response: NSURLResponse?
        let queue:NSOperationQueue = NSOperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse!, urlData: NSData!, error: NSError!) -> Void in
            /* Your code */
            let res = response as! NSHTTPURLResponse!
            if res != nil{
                println(res.statusCode)
                if res.statusCode >= 200 && res.statusCode < 300{
                    //let json = JSON(data: urlData!)
                    let JSONObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(urlData!, options: nil, error: nil)
                    
                    if let returnedVenues = JSONObject as? [AnyObject] {
                        for venue in returnedVenues {
                            let venueJson = JSON(venue)
                            // Parse the JSON file using SwiftlyJSON
                            APICalls.parseJSONDeals(venueJson)
                        }
                        completion(true)
                    }
                }
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
     /*   let venue = Venue()
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
        venue.swipeValue = 3   // deal only*/
        
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
        var fullData = NSMutableData()
        
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