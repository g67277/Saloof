//
//  RegisterRestaurantVC.swift
//  Saloof
//
//  Created by Nazir Shuqair on 7/14/15.
//  Copyright (c) 2015 SNASTek. All rights reserved.
//

import UIKit
import SwiftyJSON

class RegisterRestaurantVC: UIViewController {
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var emailAddressField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordCField: UITextField!
    var passwordValid = false
    
    let authenticationCall = AuthenticationCalls()
    let validation = Validation()
    let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // Addes guesture to hide keyboard when tapping on the view
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
        userName.attributedPlaceholder = NSAttributedString(string:"Username",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        passwordField.attributedPlaceholder = NSAttributedString(string:"Password",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        emailAddressField.attributedPlaceholder = NSAttributedString(string:"Email Address",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        passwordCField.attributedPlaceholder = NSAttributedString(string:"Confirm Password",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        
    }
    
    
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func onClick(_sender:UIButton){
        
        if _sender.tag == 0{
            
            self.validateInput()
            
        }else if _sender.tag == 1{
            
            self.navigationController?.popViewControllerAnimated(true)
            
        }
        
    }
    
    @IBAction func returnToReg1 (segue:UIStoryboardSegue) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func validateInput(){
        
        //testing only
        //username.text = "naz"
        //emailAddressField.text = "naz@naz.com"
//        passwordField.text = "Test@123"
//        passwordCField.text = "Test@123"
        // Delete above
        
        if validation.validateInput(userName.text!, check: 2, title: "Somethings Missing", message: "Please enter a valid username")
            && validation.validateEmail(emailAddressField.text!)
            && validation.validatePassword(passwordField.text!, cpass: passwordCField.text!){
                
                let containerView = CreateActivityView.createView(UIColor.blackColor(), frame: self.view.frame)
                let aIView = CustomActivityView(frame: CGRect (x: 0, y: 0, width: 100, height: 100), color: UIColor.whiteColor(), size: CGSize(width: 100, height: 100))
                aIView.center = containerView.center
                containerView.addSubview(aIView)
                containerView.center = self.view.center
                self.view.addSubview(containerView)
                aIView.startAnimation()
                
                if Reachability.isConnectedToNetwork(){
                    let post:NSString = "{\"UserName\":\"\(userName.text)\",\"Email\":\"\(emailAddressField.text)\",\"Password\":\"\(passwordField.text)\",\"ConfirmPassword\":\"\(passwordCField.text)\",\"IsBusiness\":\"true\"}"
                    authenticationCall.registerUser(post) { result in
                        let stringPost="grant_type=password&username=\(self.userName.text)&password=\(self.passwordField.text)"
                        if result{
                            self.authenticationCall.signIn(stringPost){result in
                                if result{
                                    dispatch_async(dispatch_get_main_queue()){
                                        aIView.stopAnimation()
                                        containerView.removeFromSuperview()
                                        self.performSegueWithIdentifier("toRegister2", sender: nil)
                                    }
                                }
                            }
                        }else{
                            dispatch_async(dispatch_get_main_queue()){
                                aIView.stopAnimation()
                                containerView.removeFromSuperview()
                            }
                        }
                    }
                }else{
                    aIView.stopAnimation()
                    containerView.removeFromSuperview()
                    validation.displayAlert("Oops", message: "Looks like you're offline, try again later")
                }
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBarHidden = true
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        // restore the navigation bar to origional
        //        let navBar:UINavigationBar! =  self.navigationController?.navigationBar
        //        navBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
        //        navBar.shadowImage = nil
        // navBar the background color to whatever we choose
        //bar.backgroundColor = UIColor.clearColor()
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
