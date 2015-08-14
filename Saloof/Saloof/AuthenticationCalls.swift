//
//  AuthenticationCalls.swift
//  Saloof
//
//  Created by Nazir Shuqair on 7/22/15.
//  Copyright (c) 2015 SNASTek. All rights reserved.
//

import UIKit
import SwiftyJSON

public class AuthenticationCalls {
    
    public func signIn(post: NSString, completion: Bool -> ()){
        
        var url:NSURL = NSURL(string: "http://ec2-52-2-195-214.compute-1.amazonaws.com/Token")!
        var postData:NSData = post.dataUsingEncoding(NSASCIIStringEncoding)!
        var postLength:NSString = String( post.length )
        var request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.HTTPBody = postData
        request.timeoutInterval = 10
        request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
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
                
                if(json["access_token"] != nil){
                    
                    debugPrint("Login Success")
                    
                    var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                    prefs.setObject(json["access_token"].string!, forKey: "TOKEN")
                    var role: String = json["role"].string!
                    if role == "business"{
                        prefs.setObject(true, forKey: "ROLE")
                    }else{
                        prefs.setObject(false, forKey: "ROLE")
                    }
                    prefs.synchronize()
                    
                    completion(true)
                    
                } else {
                    var error_msg:NSString
                    if json["error_description"] != nil {
                        error_msg = json["error_description"].string!
                        debugPrint("error response")
                    } else {
                        error_msg = "Unknown Error"
                        debugPrint("Unknown Error")
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        var alertView:UIAlertView = UIAlertView()
                        alertView.title = "Sign in Failed!"
                        alertView.message = error_msg as String
                        alertView.delegate = self
                        alertView.addButtonWithTitle("OK")
                        alertView.show()
                    }
                    completion(false)
                }
            }else {
                var error_msg:NSString
                let json = JSON(data: urlData!)
                println(json["error_description"])
                if json["error_description"] != nil {
                    error_msg = json["error_description"].string!
                    debugPrint("error response")
                } else {
                    error_msg = "Unknown Error"
                    debugPrint("Unknown Error")
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    var alertView:UIAlertView = UIAlertView()
                    alertView.title = "Sign in Failed!"
                    alertView.message = error_msg as String
                    alertView.delegate = self
                    alertView.addButtonWithTitle("OK")
                    alertView.show()
                }
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
    
    func registerRestaurant(call: NSString, token: String, completion: Bool ->()){
        
        var url:NSURL = NSURL(string: "http://ec2-52-2-195-214.compute-1.amazonaws.com/api/Venue")!
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
            /* Your code */
            let res = response as! NSHTTPURLResponse!
            if res != nil{
            println(res.statusCode)
            if res.statusCode >= 200 && res.statusCode < 300{
                completion(true)
            }else{
                
                let json = JSON(data: urlData!)
                println(json)
                var alertView:UIAlertView = UIAlertView()
                alertView.title = "Sign in Failed!"
                alertView.message = json["error_message"].string!
                alertView.delegate = self
                alertView.addButtonWithTitle("OK")
                alertView.show()
                debugPrint(json["error_description"].string!)
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
    
    /*func registerRestaurant(call: NSString, token: String) -> (Bool){
        
        if Reachability.isConnectedToNetwork(){
            
            var url:NSURL = NSURL(string: "http://ec2-52-2-195-214.compute-1.amazonaws.com/api/Venue")!
            
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
        
    }*/
    
    func registerUser(post: NSString, completion: Bool -> ()){
        
        var url:NSURL = NSURL(string: "http://ec2-52-2-195-214.compute-1.amazonaws.com/api/Account/Register")!
        
        var postData:NSData = post.dataUsingEncoding(NSUTF8StringEncoding)!
        
        var postLength:NSString = String( postData.length )
        
        var request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.HTTPBody = postData
        request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        
        let queue:NSOperationQueue = NSOperationQueue()

        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse!, urlData: NSData!, error: NSError!) -> Void in
            /* Your code */
            let res = response as! NSHTTPURLResponse!
            if res != nil{
            println(res.statusCode)
            if res.statusCode >= 200 && res.statusCode < 300{
                if res.statusCode == 200{
                    completion(true)
                }else{
                    let json = JSON(data: urlData!)
                    var error_msg:NSString
                    if json["error_description"] != nil {
                        error_msg = json["error_description"].string!
                    } else {
                        error_msg = "Unknown Error"
                    }
                    println(error_msg)
                    var alertView:UIAlertView = UIAlertView()
                    alertView.title = "Sign Up Failed!"
                    alertView.message = error_msg as String
                    alertView.delegate = self
                    alertView.addButtonWithTitle("OK")
                    alertView.show()
                }
            }else{
                
                let json = JSON(data: urlData!)
                var error_msg = json["Message"].string!
                println(error_msg)
                var alertView:UIAlertView = UIAlertView()
                alertView.title = "Sign Up Failed!"
                alertView.message = error_msg as String
                alertView.delegate = self
                alertView.addButtonWithTitle("OK")
                alertView.show()
            }
                completion(false)

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
    
    /*func registerUser(post: NSString) -> (Bool){
        
        if Reachability.isConnectedToNetwork(){
            
            NSLog("PostData: %@",post);
            
            var url:NSURL = NSURL(string: "http://ec2-52-2-195-214.compute-1.amazonaws.com/api/Account/Register")!
            
            var postData:NSData = post.dataUsingEncoding(NSUTF8StringEncoding)!
            
            var postLength:NSString = String( postData.length )
            
            var request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.HTTPBody = postData
            request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            
            var reponseError: NSError?
            var response: NSURLResponse?
            
            var urlData: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError)
            
            if ( urlData != nil ) {
                let res = response as! NSHTTPURLResponse!;
                
                NSLog("Response code: %ld", res.statusCode);
                if (res.statusCode >= 200 && res.statusCode < 300)
                {
                    
                    if(res.statusCode == 200)
                    {
                        NSLog("Sign Up SUCCESS");
                        return true
                    } else {
                        
                        var error: NSError?
                        
                        let jsonData:NSDictionary = NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers , error: &error) as! NSDictionary
                        
                        var error_msg:NSString
                        
                        if jsonData["error_message"] as? NSString != nil {
                            error_msg = jsonData["error_message"] as! NSString
                        } else {
                            error_msg = "Unknown Error"
                        }
                        var alertView:UIAlertView = UIAlertView()
                        alertView.title = "Sign Up Failed!"
                        alertView.message = error_msg as String
                        alertView.delegate = self
                        alertView.addButtonWithTitle("OK")
                        alertView.show()
                        
                    }
                    
                } else if res.statusCode == 400 {
                    
                    var error: NSError?
                    
                    let jsonData:NSDictionary = NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers , error: &error) as! NSDictionary
                    
                    println(jsonData["error_message"])
                    
                    var alertView:UIAlertView = UIAlertView()
                    alertView.title = "Sign Up Failed!"
                    alertView.message = "Email address is already taken"
                    alertView.delegate = self
                    alertView.addButtonWithTitle("OK")
                    alertView.show()
                }
            }  else {
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
    }*/
    
    func resetPassword(email: NSString) -> (Bool){
        
        
        if Reachability.isConnectedToNetwork(){
            var url:NSURL = NSURL(string: "http://ec2-52-2-195-214.compute-1.amazonaws.com/api/Account/ForgotPassword?email=\(email)")!
            
            
            var request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
            
            
            var reponseError: NSError?
            var response: NSURLResponse?
            
            var urlData: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError)
            
            if ( urlData != nil ) {
                let res = response as! NSHTTPURLResponse!;
                
                NSLog("Response code: %ld", res.statusCode);
                
                if (res.statusCode >= 200 && res.statusCode < 300)
                {
                    
                    if(res.statusCode == 201 || res.statusCode == 200)
                    {
                        NSLog("Sign Up SUCCESS");
                        return true
                    } else {
                        
                        var error: NSError?
                        
                        let jsonData:NSDictionary = NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers , error: &error) as! NSDictionary
                        
                        var error_msg:NSString
                        
                        if jsonData["error_message"] as? NSString != nil {
                            error_msg = jsonData["error_message"] as! NSString
                        } else {
                            error_msg = "Unknown Error"
                        }
                        var alertView:UIAlertView = UIAlertView()
                        alertView.title = "Sign Up Failed!"
                        alertView.message = error_msg as String
                        alertView.delegate = self
                        alertView.addButtonWithTitle("OK")
                        alertView.show()
                        
                    }
                    
                } else if res.statusCode == 400 {
                    
                    var error: NSError?
                    
                    let jsonData:NSDictionary = NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers , error: &error) as! NSDictionary
                    
                    println(jsonData["error_message"])
                    
                    var alertView:UIAlertView = UIAlertView()
                    alertView.title = "Sign Up Failed!"
                    alertView.message = "Email address is already taken"
                    alertView.delegate = self
                    alertView.addButtonWithTitle("OK")
                    alertView.show()
                }
            }  else {
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
    
}
