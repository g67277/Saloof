//
//  ForgotPasswordVC.swift
//  FareDeal
//
//  Created by Angela Smith on 7/29/15.
//  Copyright (c) 2015 SNASTek. All rights reserved.
//

import UIKit

class ForgotPasswordVC: UIViewController {
    
    @IBOutlet var emailTextField: UITextField!
    let authenticationCall:AuthenticationCalls = AuthenticationCalls()
    let validation = Validation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Addes guesture to hide keyboard when tapping on the view
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
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
    
}
