//
//  RegisterUserVC.swift
//  Saloof
//
//  Created by Nazir Shuqair on 7/14/15.
//  Copyright (c) 2015 SNASTek. All rights reserved.
//

import UIKit

class RegisterUserVC: UIViewController {
    
    //@IBOutlet var registerButtonView: UIView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordCField: UITextField!
    
    let authenticationCall:AuthenticationCalls = AuthenticationCalls()
    let validation = Validation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // Addes guesture to hide keyboard when tapping on the view
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        usernameField.attributedPlaceholder = NSAttributedString(string:"Username",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        emailField.attributedPlaceholder = NSAttributedString(string:"Email Address",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        passwordField.attributedPlaceholder = NSAttributedString(string:"Password",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        passwordCField.attributedPlaceholder = NSAttributedString(string:"Confirm Password",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
    }
    
    override func viewDidLayoutSubviews() {
        
        //registerButtonView.roundCorners(.AllCorners, radius: 14)
    }
    
    
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func onClick(_sender:UIButton){
        
        if _sender.tag == 0{
            
            //sign up here
            
            var testing = usernameField.text
            
            if validation.validateInput(usernameField.text, check: 2, title: "Somethings Missing", message: "Please enter a valid username")
                && validation.validateEmail(emailField.text)
                && validation.validatePassword(passwordField.text, cpass: passwordCField.text){
                    var post:NSString = "{\"UserName\":\"\(usernameField.text)\",\"Email\":\"\(emailField.text)\",\"Password\":\"\(passwordField.text)\",\"ConfirmPassword\":\"\(passwordCField.text)\",\"IsBusiness\":\"false\"}"
                    
                    var containerView = CreateActivityView.createView(UIColor.blackColor(), frame: self.view.frame)
                    var aIView = CustomActivityView(frame: CGRect (x: 0, y: 0, width: 100, height: 100), color: UIColor.whiteColor(), size: CGSize(width: 100, height: 100))
                    aIView.center = containerView.center
                    containerView.addSubview(aIView)
                    containerView.center = self.view.center
                    self.view.addSubview(containerView)
                    aIView.startAnimation()
                    
                    if Reachability.isConnectedToNetwork(){
                        authenticationCall.registerUser(post){ result in
                            
                            if result{
                                var stringPost="grant_type=password&username=\(self.usernameField.text)&password=\(self.passwordField.text)"
                                
                                self.authenticationCall.signIn(stringPost){ result in
                                    if result {
                                        dispatch_async(dispatch_get_main_queue()){
                                            aIView.stopAnimation()
                                            containerView.removeFromSuperview()
                                            self.navigationController?.popViewControllerAnimated(false)
                                        }
                                    }else{
                                        dispatch_async(dispatch_get_main_queue()){
                                            aIView.stopAnimation()
                                            containerView.removeFromSuperview()
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
            
        }else if _sender.tag == 1{
            
            self.navigationController?.popViewControllerAnimated(true)
            
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
