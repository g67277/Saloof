//
//  UserProfileVC.swift
//  Saloof
//
//  Created by Angela Smith on 8/22/15.
//  Copyright (c) 2015 SNASTek. All rights reserved.
//

import UIKit

class UserProfileVC: UIViewController {

    let prefs: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    let authenticationCall = AuthenticationCalls()
    let validation = Validation()
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var emailTextfield: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // close search when user taps outside search field
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)

        emailTextfield.attributedPlaceholder = NSAttributedString(string:"Email Address",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        // "Saloof.UserName")
        var userName = prefs.stringForKey("Saloof.UserName")
        userNameLabel.text = userName
        // Add the second button to the nav bar
        var logOutButton = UIBarButtonItem(title: "Log Out", style: .Plain, target: self, action:"logUserOut")
        self.navigationItem.rightBarButtonItem = logOutButton
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func logUserOut () {
        //LOG OUT USER
        prefs.setObject(nil, forKey: "TOKEN")
        prefs.setObject(nil, forKey: "Saloof.UserName")
        self.dismissViewControllerAnimated(true, completion: nil)
    }


    @IBAction func onReset(sender: AnyObject) {
        if validation.validateEmail(emailTextfield.text){
            if authenticationCall.resetPassword(emailTextfield.text){
                var refreshAlert = UIAlertController(title: "Done", message: "Check your email for a reset link", preferredStyle: UIAlertControllerStyle.Alert)
                refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: {(action: UIAlertAction!) in
                    self.navigationController?.popViewControllerAnimated(true)
                }))
                self.presentViewController(refreshAlert, animated: true, completion: nil)
            }
        }

        
    }
    
    
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}
