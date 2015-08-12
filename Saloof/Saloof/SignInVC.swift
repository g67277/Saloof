//
//  SignInVC.swift
//  Saloof
//
//  Created by Nazir Shuqair on 7/14/15.
//  Copyright (c) 2015 SNASTek. All rights reserved.
//

import UIKit

class SignInVC: UIViewController {
    
    
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    let authenticationCall:AuthenticationCalls = AuthenticationCalls()
    let validation = Validation()
    let apiCall = APICalls()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // Addes guesture to hide keyboard when tapping on the view
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
        
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if (prefs.objectForKey("TOKEN") == nil) || (prefs.objectForKey("restID") == nil) {
            debugPrint("NO token or restaurant ID")
        } else{
            //self.performSegueWithIdentifier("toMain", sender: self)
            var storyboard = UIStoryboard(name: "Business", bundle: nil)
            var controller = storyboard.instantiateViewControllerWithIdentifier("InitialBusinessView")as! UIViewController
            self.presentViewController(controller, animated: true, completion: nil)
        }
        
        
    }
    
    override func viewDidLayoutSubviews() {
        // set the rounded corners after autolayout has finished
        //logInButtonView.roundCorners(.AllCorners, radius: 14)
    }
    
    
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func onClick(_sender:UIButton){
        
        if _sender.tag == 0{
            
            if validation.validateInput(userNameField.text, check: 3, title: "Too Short", message: "Please enter a valid username")
                && validation.validateInput(passwordField.text, check: 0, title: "Empty Password", message: "Please enter a password"){
                    
                    var containerView = CreateActivityView.createView(UIColor.blackColor())
                    var aIView = CustomActivityView(frame: CGRect (x: 0, y: 0, width: 70, height: 70), color: UIColor.whiteColor(), size: CGSize(width: 70, height: 70))
                    aIView.center = containerView.center
                    containerView.addSubview(aIView)
                    containerView.center = self.view.center
                    self.view.addSubview(containerView)
                    aIView.startAnimation()
                    
                    var stringPost="grant_type=password&username=\(userNameField.text)&password=\(passwordField.text)"
                    
                    authenticationCall.signIn(stringPost){ result in
                        if result{
                            var token = self.prefs.stringForKey("TOKEN")
                            if self.prefs.boolForKey("ROLE"){
                                APICalls.getMyRestaurant(token!, completion: { result in
                                    
                                    if result{
                                        dispatch_async(dispatch_get_main_queue()){
                                            var storyboard = UIStoryboard(name: "Business", bundle: nil)
                                            var controller = storyboard.instantiateViewControllerWithIdentifier("InitialBusinessView")as! UIViewController
                                            self.presentViewController(controller, animated: true, completion: nil)
                                        }
                                    }else{
                                        dispatch_async(dispatch_get_main_queue()){
                                            var refreshAlert = UIAlertController(title: "Registration Not Complete", message: "You don't have a restaurant registered yet, do you want to register one now?", preferredStyle: UIAlertControllerStyle.Alert)
                                            refreshAlert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: {(action: UIAlertAction!) in
                                                self.performSegueWithIdentifier("toReg2", sender: nil)
                                            }))
                                            refreshAlert.addAction(UIAlertAction(title: "No", style: .Default, handler: {(action: UIAlertAction!) in
                                            }))
                                            self.presentViewController(refreshAlert, animated: true, completion: nil)
                                        }
                                    }
                                })
                            }else{
                                dispatch_async(dispatch_get_main_queue()){
                                    self.validation.displayAlert("No Permission", message: "Please create a business account to access the business side")

                                }
                            }
                        }
                        dispatch_async(dispatch_get_main_queue()) {
                            self.userNameField.text = ""
                            self.passwordField.text = ""
                            aIView.stopAnimation()
                            containerView.removeFromSuperview()
                        }
                    }
                    
//                    if authenticationCall.signIn(stringPost){
//                        
//                        prefs.setObject(userNameField.text, forKey: "USERNAME")
//                        var token = prefs.stringForKey("TOKEN")
//                        if prefs.boolForKey("ROLE"){
//                            if apiCall.getMyRestaurant(token!){
//                                //self.performSegueWithIdentifier("toMain", sender: self)
//                                aIView.stopAnimation()
//                                var storyboard = UIStoryboard(name: "Business", bundle: nil)
//                                var controller = storyboard.instantiateViewControllerWithIdentifier("InitialBusinessView")as! UIViewController
//                                self.presentViewController(controller, animated: true, completion: nil)
//                            }else{
//                                aIView.stopAnimation()
//                                var refreshAlert = UIAlertController(title: "Registration Not Complete", message: "You don't have a restaurant registered yet, do you want to register one now?", preferredStyle: UIAlertControllerStyle.Alert)
//                                refreshAlert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: {(action: UIAlertAction!) in
//                                    self.performSegueWithIdentifier("toReg2", sender: nil)
//                                }))
//                                refreshAlert.addAction(UIAlertAction(title: "No", style: .Default, handler: {(action: UIAlertAction!) in
//                                }))
//                                self.presentViewController(refreshAlert, animated: true, completion: nil)
//                            }
//                        }else{
//                            aIView.stopAnimation()
//                            validation.displayAlert("No Permission", message: "Please create a business account to access the business side")
//                        }
//                    }
            }
        } else if _sender.tag == 1{
            if (prefs.objectForKey("TOKEN") == nil) {
                self.performSegueWithIdentifier("toReg1", sender: nil)
            } else  {
                var refreshAlert = UIAlertController(title: "Continue?", message: "Want to continue your last registration?", preferredStyle: UIAlertControllerStyle.Alert)
                refreshAlert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: {(action: UIAlertAction!) in
                    self.performSegueWithIdentifier("toReg2", sender: nil)
                }))
                refreshAlert.addAction(UIAlertAction(title: "No", style: .Default, handler: {(action: UIAlertAction!) in
                    self.performSegueWithIdentifier("toReg1", sender: nil)
                }))
                self.presentViewController(refreshAlert, animated: true, completion: nil)
            }
        }
        
    }
    
    @IBAction func returnToLogInScreen (segue:UIStoryboardSegue) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "toUserSide") {
            prefs.setInteger(2, forKey: "SIDE")
        }else if (segue.identifier == "toReg1"){
            
        }else if (segue.identifier == "toReg2"){
            var svc = segue.destinationViewController as! RegisterRestaurantVC2;
            
            svc.continueSession = true
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        // Hide the navigation bar to display the full location image
        navigationController?.navigationBarHidden = true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
