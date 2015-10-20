//
//  Validation.swift
//  Saloof
//
//  Created by Nazir Shuqair on 8/2/15.
//  Copyright (c) 2015 SNASTek. All rights reserved.
//

import Foundation

public class Validation{
    
    //Validates entery lenght based on passed check integer
    func validateInput(input: String, check: Int, title: String, message: String) -> Bool{
        
        if input.characters.count > check {
            return true
        }else{
            displayAlert(title, message: message)
            return false
        }
        
    }
    
    func validateAddress(street: String, city: String, zipcode: String, lat: Double, lng: Double) -> (formattedString: String, valid: Bool){
        
        if street.characters.count > 6 {
            
            if city.characters.count > 2{
                if zipcode.characters.count == 5 {
                    if lat != 0.0 && lng != 0.0 {
                        return ("\(street), \(city), \(zipcode)", true)
                    }else{
                        displayAlert("Invalid address", message: "Please enter a valid address")
                        return ("invalid", false)
                    }
                }else{
                    displayAlert("Invalid zipcode", message: "Please enter a valid zipcode ")
                    return ("invalid", false)
                }
            }else{
                displayAlert("Too Short", message: "Please enter a valid city ")
                return ("invalid", false)
            }
        }else {
            displayAlert("Too Short", message: "Please enter a valid street address")
            return ("invalid", false)
        }
    }
    
    func validateEmail(candidate: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        if NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluateWithObject(candidate){
            return true
        }else {
            displayAlert("Invalid Email ", message: "Please enter a valid email")
            return false
        }
        
    }
    
    func validatePassword(pass: String, cpass: String) -> Bool{
        
        if pass.characters.count > 5 {
            
            if pass == cpass{
                return true
            }else{
                displayAlert("Password Error", message: "Password does not match")
                return false
            }
            
        }else{
            displayAlert("Password Error", message: "Password needs to be at least 6 characters")
            return false
        }
        
    }
    
    func category(input: String) -> Bool{
        
        if input == "Category" || input == ""{
            displayAlert("Invalid Category", message: "Please select a valid category")
            return false
        }else{
            return true
        }
    }
    
    func validatePhone(phone: String, check: Int, title: String, message: String) -> Bool{
        
        if phone.characters.count == check{
            return true
        }else{
            displayAlert(title, message: message)
            return false
        }
        
    }

    
    func shouldValidateWebsiteUrl(websiteString: String, completion: Bool -> ()){
        // try running an asynchronous request to the site to see if it is active
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let url = NSURL(string: websiteString as String)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "HEAD"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 10.0
        
        NSURLConnection.sendAsynchronousRequest(request, queue:NSOperationQueue.mainQueue(), completionHandler:
            {(response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                let rsp = response as! NSHTTPURLResponse?
                // return the status code
                //completion(rsp?.statusCode == 200)
                completion((rsp?.statusCode >= 200 && rsp?.statusCode < 400) || rsp?.statusCode == 405)
        })
    }

    
    func formatHours(weekO: String, weekC: String, weekendO: String, weekendC: String) -> (weekdayHours: String, weekendHours: String){
        
        let weekdayString = "\(weekO)-\(weekC)"
        let weekendString = "\(weekendO)-\(weekendC)"
        return (weekdayString, weekendString)
    }
    
    func displayAlert(title: String, message: String){
        let alertView:UIAlertView = UIAlertView()
        alertView.title = title
        alertView.message = message
        alertView.delegate = self
        alertView.addButtonWithTitle("OK")
        alertView.show()
    }
    
}