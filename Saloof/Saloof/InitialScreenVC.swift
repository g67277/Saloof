//
//  InitialScreenVC.swift
//  Saloof
//
//  Created by Nazir Shuqair on 7/14/15.
//  Copyright (c) 2015 SNASTek. All rights reserved.
//

import UIKit

class InitialScreenVC: UIViewController {
    
    @IBOutlet var businessBlendView: UIView!
    @IBOutlet var userBlendView: UIView!
    let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if prefs.integerForKey("SIDE") == 1 {
            self.performSegueWithIdentifier("toBusiness", sender: self)
            
        } else if prefs.integerForKey("SIDE") == 2 {
            self.performSegueWithIdentifier("toUser", sender: self)
            
        } else{
            debugPrint("Sides have not been chosen yet", terminator: "")
        }
        
    }
    
    @IBAction func onClick(_sender:UIButton){
        
        if _sender.tag == 0{
            prefs.setInteger(1, forKey: "SIDE")
        }else if _sender.tag == 1{
            prefs.setInteger(2, forKey: "SIDE")
        }
        
    }
    
    @IBAction func returnToInitialScreen (segue:UIStoryboardSegue) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        // Hide the navigation bar to display the full location image
        let navBar:UINavigationBar! =  self.navigationController?.navigationBar
        if navBar != nil{
            navBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
            navBar.shadowImage = UIImage()
            navBar.backgroundColor = UIColor.clearColor()
        }
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        // restore the navigation bar to origional
        let navBar:UINavigationBar! =  self.navigationController?.navigationBar
        if navBar != nil{
            navBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
            navBar.shadowImage = nil
        }
    }
    
    
}
