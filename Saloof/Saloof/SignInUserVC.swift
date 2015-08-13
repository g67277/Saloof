//
//  LoginVC.swift
//  authentication test
//
//  Created by Nazir Shuqair on 7/14/15.
//  Copyright (c) 2015 SNASTek. All rights reserved.
//

import UIKit

class SignInUserVC: UIViewController {
    
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet var logInButtonView: UIView!
    
    
    let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    let authenticationCall:AuthenticationCalls = AuthenticationCalls()
    let validation = Validation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // Addes guesture to hide keyboard when tapping on the view
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
        userNameField.attributedPlaceholder = NSAttributedString(string:"Username",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        passwordField.attributedPlaceholder = NSAttributedString(string:"Password",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        //authenticationCall.displayIndicator(self.view, stop: false)
        
    }
    
    override func viewDidLayoutSubviews() {
        // set the rounded corners after autolayout has finished
        //logInButtonView.roundCorners(.AllCorners, radius: 14)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if (prefs.objectForKey("TOKEN") == nil) {
            debugPrint("NO token")
            //self.performSegueWithIdentifier("goto_login", sender: self)
        } else {
            //self.performSegueWithIdentifier("toUserMain", sender: self)
            var storyboard = UIStoryboard(name: "User", bundle: nil)
            var controller = storyboard.instantiateViewControllerWithIdentifier("InitialUserController")as! UIViewController
            self.presentViewController(controller, animated: true, completion: nil)
        }
        
    }
    
    
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func onClick(_sender:UIButton){
        
        if _sender.tag == 0{
            
            
            if validation.validateInput(userNameField.text, check: 3, title: "Too Short", message: "Please enter a valid username")
                && validation.validateInput(passwordField.text, check: 0, title: "Empty Password", message: "Please enter a password"){
                    
                    var containerView = CreateActivityView.createView(UIColor.blackColor(), frame: self.view.frame)
                    var aIView = CustomActivityView(frame: CGRect (x: 0, y: 0, width: 100, height: 100), color: UIColor.whiteColor(), size: CGSize(width: 100, height: 100))
                    aIView.center = containerView.center
                    containerView.addSubview(aIView)
                    containerView.center = self.view.center
                    self.view.addSubview(containerView)
                    aIView.startAnimation()
                    
                    var stringPost="grant_type=password&username=\(userNameField.text)&password=\(passwordField.text)"
                    if Reachability.isConnectedToNetwork(){
                        authenticationCall.signIn(stringPost){ result in
                            
                            if result{
                                dispatch_async(dispatch_get_main_queue()){
                                    aIView.stopAnimation()
                                    containerView.removeFromSuperview()
                                    self.userNameField.text = ""
                                    self.passwordField.text = ""
                                    self.prefs.setObject(self.userNameField.text, forKey: "USERNAME")
                                    var storyboard = UIStoryboard(name: "User", bundle: nil)
                                    var controller = storyboard.instantiateViewControllerWithIdentifier("InitialUserController")as! UIViewController
                                    self.presentViewController(controller, animated: true, completion: nil)
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
            
        } else if _sender.tag == 1 {
            self.performSegueWithIdentifier("userForgotPassword", sender: self)
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func returnToLogInScreen (segue:UIStoryboardSegue) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "toBusinessSide") {
            prefs.setInteger(1, forKey: "SIDE")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        // Hide the navigation bar to display the full location image
        navigationController?.navigationBarHidden = true
    }
    
    
}

extension UIView {
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.CGPath
        self.layer.mask = mask
    }
    
    func setBorder() {
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.borderWidth = 1.5
        
        // drop shadow
        self.layer.shadowColor = UIColor.lightGrayColor().CGColor
        self.layer.shadowOpacity = 0.8
        self.layer.shadowRadius = 1.3
        self.layer.shadowOffset = CGSizeMake(1.0, 1.0)
    }
}
