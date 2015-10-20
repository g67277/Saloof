//
//  ForgotPasswordUserVC.swift
//  Saloof
//
//  Created by Angela Smith on 7/29/15.
//  Copyright (c) 2015 SNASTek. All rights reserved.
//

import UIKit

class ForgotPasswordUserVC: UIViewController {
    
    
    @IBOutlet var emailTextField: UITextField!
    //@IBOutlet var resetPasswordButtonView: UIView!
    let authenticationCall = AuthenticationCalls()
    let validation = Validation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Addes guesture to hide keyboard when tapping on the view
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
        emailTextField.attributedPlaceholder = NSAttributedString(string:"Email Address",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
    }
    
    override func viewDidLayoutSubviews() {
        // set the rounded corners after autolayout has finished
        //resetPasswordButtonView.roundCorners(.AllCorners, radius: 14)
    }
    
    @IBAction func onClick(_sender:UIButton){
        
        if _sender.tag == 0 {
            
            if validation.validateEmail(emailTextField.text!){
                if authenticationCall.resetPassword(emailTextField.text!){
                    let refreshAlert = UIAlertController(title: "Done", message: "Check your email for a reset link", preferredStyle: UIAlertControllerStyle.Alert)
                    refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: {(action: UIAlertAction!) in
                        self.navigationController?.popViewControllerAnimated(true)
                    }))
                    self.presentViewController(refreshAlert, animated: true, completion: nil)
                }
            }
            
        } else if _sender.tag == 1 {
            self.navigationController?.popViewControllerAnimated(true)
            
        }
    }
    
    
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        // Hide the navigation bar to display the full location image
        navigationController?.navigationBarHidden = true
    }
    
    
    
}
