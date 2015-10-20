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
        
        let url:NSURL = NSURL(string: "http://ec2-52-2-195-214.compute-1.amazonaws.com/Token")!
        let postData:NSData = post.dataUsingEncoding(NSASCIIStringEncoding)!
        let postLength:NSString = String( post.length )
        let request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.HTTPBody = postData
        request.timeoutInterval = 10
        request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
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
                
                if(json["access_token"] != nil){
                    
                    debugPrint("Login Success")
                    
                    let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                    prefs.setObject(json["access_token"].string!, forKey: "TOKEN")
                    let role: String = json["role"].string!
                    if role == "business"{
                        prefs.setObject(true, forKey: "ROLE")
                    }else{
                        prefs.setObject(false, forKey: "ROLE")
                        prefs.setObject(json["userName"].string!, forKey: "Saloof.UserName")
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
                        let alertView:UIAlertView = UIAlertView()
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
                print(json["error_description"])
                if json["error_description"] != nil {
                    error_msg = json["error_description"].string!
                    debugPrint("error response")
                } else {
                    error_msg = "Unknown Error"
                    debugPrint("Unknown Error")
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    let alertView:UIAlertView = UIAlertView()
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
    
    func registerRestaurant(call: NSString, token: String, completion: Bool ->()){
        
        let url:NSURL = NSURL(string: "http://ec2-52-2-195-214.compute-1.amazonaws.com/api/Venue")!
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
        //var reponseError: NSError?
       // var response: NSURLResponse?
        let queue:NSOperationQueue = NSOperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse?, urlData: NSData?, error: NSError?) -> Void in
            /* Your code */
            /* Your code */
            let res = response as! NSHTTPURLResponse!
            if res != nil{
            print(res.statusCode)
            if res.statusCode >= 200 && res.statusCode < 300{
                completion(true)
            }else{
                
                //var error: NSError?
                
                //let jsonData:NSDictionary = NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers , error: &error) as! NSDictionary
                
                let json = JSON(data: urlData!)
                print(json)
                let alertView:UIAlertView = UIAlertView()
                alertView.title = "Registration Failed"
                alertView.message = "Please try again later"
                alertView.delegate = self
                alertView.addButtonWithTitle("OK")
                alertView.show()
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

    
    func registerUser(post: NSString, completion: Bool -> ()){
        
        let url:NSURL = NSURL(string: "http://ec2-52-2-195-214.compute-1.amazonaws.com/api/Account/Register")!
        
        let postData:NSData = post.dataUsingEncoding(NSUTF8StringEncoding)!
        
        let postLength:NSString = String( postData.length )
        
        let request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.HTTPBody = postData
        request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        
        let queue:NSOperationQueue = NSOperationQueue()

        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse?, urlData: NSData?, error: NSError?) -> Void in
            /* Your code */
            let res = response as! NSHTTPURLResponse!
            if res != nil{
            print(res.statusCode)
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
                    print(error_msg)
                    let alertView:UIAlertView = UIAlertView()
                    alertView.title = "Sign Up Failed!"
                    alertView.message = error_msg as String
                    alertView.delegate = self
                    alertView.addButtonWithTitle("OK")
                    alertView.show()
                }
            }else{

                let json = JSON(data: urlData!)
                if json["ModelState"] != nil{
                    let error_msg = json["ModelState"][""][0].string!
                    print(error_msg)
                    dispatch_async(dispatch_get_main_queue()){
                        let alertView:UIAlertView = UIAlertView()
                        alertView.title = "Sign Up Failed!"
                        alertView.message = error_msg as String
                        alertView.delegate = self
                        alertView.addButtonWithTitle("OK")
                        alertView.show()
                    }
                }
                
            }
                completion(false)

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
    
    
    func resetPassword(email: NSString) -> (Bool){
        
        
        if Reachability.isConnectedToNetwork(){
            let url:NSURL = NSURL(string: "http://ec2-52-2-195-214.compute-1.amazonaws.com/api/Account/ForgotPassword?email=\(email)")!
            
            
            let request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
            
            // TODO: FIX error handling for swift 2.0
            //let reponseError: NSError?
            var response: NSURLResponse?
            var urlData: NSData?
            
            do {
                urlData = try NSURLConnection.sendSynchronousRequest(request, returningResponse:&response)
                if (urlData != nil) {
                    let res = response as! NSHTTPURLResponse!;
                    
                    NSLog("Response code: %ld", res.statusCode);
                    
                    
                    if (res.statusCode >= 200 && res.statusCode < 300)
                    {
                        
                        if(res.statusCode == 201 || res.statusCode == 200)
                        {
                            NSLog("Sign Up SUCCESS");
                            return true
                        } else {
                            
                            // TODO: Fix error handling for Swift 2.0
                            
                            //let error: NSError?
                            
                            //let jsonData:NSDictionary = NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers , error: &error) as! NSDictionary
                            
                            //var error_msg:NSString
                            /*
                            if jsonData["error_message"] as? NSString != nil {
                            error_msg = jsonData["error_message"] as! NSString
                            } else {
                            error_msg = "Unknown Error"
                            }*/
                            let alertView:UIAlertView = UIAlertView()
                            alertView.title = "Sign Up Failed!"
                            alertView.message = "Please try again later"
                            alertView.delegate = self
                            alertView.addButtonWithTitle("OK")
                            alertView.show()
                            
                        }
                        
                    } else {
                        
                        //var error: NSError?
                        do {
                            let jsonResult = try NSJSONSerialization.JSONObjectWithData(urlData!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                            print(jsonResult)
                        } catch let error as NSError {
                            print(error)
                        }
                        //let jsonData:NSDictionary = NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers , error: &error) as! NSDictionary
                        
                        //print(jsonData["error_message"])
                        
                        let alertView:UIAlertView = UIAlertView()
                        alertView.title = "Account not found"
                        alertView.message = "Please enter the email you used when creating the account"
                        alertView.delegate = self
                        alertView.addButtonWithTitle("OK")
                        alertView.show()
                    }
                }  else {
                    let alertView:UIAlertView = UIAlertView()
                    alertView.title = "Connection Failure"
                    alertView.message = "Please try again later"
                   // if let error = reponseError {
                       // alertView.message = (error.localizedDescription)
                    //}
                    alertView.delegate = self
                    alertView.addButtonWithTitle("OK")
                    alertView.show()
                }
            } catch _ as NSError {
                //reponseError = error
                urlData = nil
            } catch {
                // Catch all error-handling
                urlData = nil
            }
            
            //let urlData: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response)
            
            
        }else{
            let alertView:UIAlertView = UIAlertView()
            alertView.title = "No network"
            alertView.message = "Please make sure you are connected then try again"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        }
        return false
    }
    
}
