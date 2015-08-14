//
//  ViewController.swift
//  Saloof
//
//  Created by Nazir Shuqair on 7/15/15.
//  Copyright (c) 2015 SNASTek. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import AssetsLibrary
import RealmSwift
import SwiftyJSON

class BusinessHome: UIViewController {
    
    @IBOutlet weak var restaurantNameLabel: UILabel!
    @IBOutlet weak var creditBalanceLabel: UILabel!
    @IBOutlet weak var dealsSelectedLabel: UILabel!
    @IBOutlet weak var dealsSwapedLabel: UILabel!
    @IBOutlet weak var monthsBtn: UIButton!
    
    @IBOutlet weak var profileImgView: UIImageView!
    let realm = Realm()
    let apiCall = APICalls()
    
    // holds all the months to display in selector
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    
    let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage(named: "navBarLogo")
        navigationItem.titleView = UIImageView(image: image)
        
        let date = NSDate();
        var formatter = NSDateFormatter();
        formatter.dateFormat = "MMMM";
        let defaultTimeZoneStr = formatter.stringFromDate(date);
        monthsBtn.setTitle(defaultTimeZoneStr, forState: UIControlState.Normal)
        
        updateDisplay()
    }
    
    override func viewWillAppear(animated: Bool) {
        updateImg()
        let creditsAvailable:Int = prefs.integerForKey("credits") as Int
        if creditsAvailable > 0 {
            creditBalanceLabel.text = "\(creditsAvailable)C"
        }else{
            creditBalanceLabel.text = "No Credits"
        }
    }
    
    func updateImg(){
        
        var data = Realm().objectForPrimaryKey(ProfileModel.self, key: prefs.stringForKey("restID")!)
        var path = data?.imgUri
        var imgURL = NSURL(string: path!)
        getUIImagefromAsseturl(imgURL!)
        
    }
    
    func updateDisplay(){
        
        var data = Realm().objectForPrimaryKey(ProfileModel.self, key: prefs.stringForKey("restID")!)
        restaurantNameLabel.text = data?.restaurantName
        updateImg()
        var apiCall = APICalls()
        if Reachability.isConnectedToNetwork(){
            apiCall.getBalance(prefs.stringForKey("restID")!, token: prefs.stringForKey("TOKEN")!, completion: { json in
                if json != nil {
                    dispatch_async(dispatch_get_main_queue()){
                         //println("returned json: \(json)")
                        var credits = json["CreditAvailable"].int!
                        var dealsSelected = json["TotalDealsPurchased"].int!
                        var dealSwapped = json["TotalDealsSwapped"].int!
                        var creditsAvailable = json["CreditAvailable"].int!
                        if creditsAvailable > 0 {
                            self.creditBalanceLabel.text = "\(creditsAvailable)C"
                        }else{
                            self.creditBalanceLabel.text = "No Credits"
                        }
                        self.dealsSelectedLabel.text = "\(dealsSelected)"
                        self.dealsSwapedLabel.text = "\(dealSwapped)"
                    }
                }
            })
            /*var json = apiCall.getBalance(prefs.stringForKey("restID")!, token: prefs.stringForKey("TOKEN")!)
            //var credits = json["CreditAvailable"].int!
            var dealsSelected = json["TotalDealsPurchased"].int!
            var dealSwapped = json["TotalDealsSwapped"].int!
            var creditsAvailable = json["CreditAvailable"].int!
            if creditsAvailable > 0 {
                creditBalanceLabel.text = "\(creditsAvailable)C"
            }else{
                creditBalanceLabel.text = "No Credits"
            }
            dealsSelectedLabel.text = "\(dealsSelected)"
            dealsSwapedLabel.text = "\(dealSwapped)" */
        }else{
            
            var alertView:UIAlertView = UIAlertView()
            alertView.title = "You're Offline"
            alertView.message = "Please connect to view summary details"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
            
            creditBalanceLabel.text = "Offline"
            dealsSelectedLabel.text = "Offline"
            dealsSwapedLabel.text = "Offline"
        }
        
    }
    
    func getUIImagefromAsseturl (url: NSURL) {
        var asset = ALAssetsLibrary()
        
        asset.assetForURL(url, resultBlock: { asset in
            if let ast = asset {
                let assetRep = ast.defaultRepresentation()
                let iref = assetRep.fullResolutionImage().takeUnretainedValue()
                let image = UIImage(CGImage: iref)
                dispatch_async(dispatch_get_main_queue(), {
                    self.profileImgView.image = image
                })
            }
            }, failureBlock: { error in
                println("Error: \(error)")
        })
    }
    
    override func viewDidLayoutSubviews() {
        profileImgView.layer.masksToBounds = false
        profileImgView.layer.borderColor = UIColor.blackColor().CGColor
        profileImgView.layer.cornerRadius = profileImgView.frame.height/2
        profileImgView.clipsToBounds = true
    }
    
    override func viewDidAppear(animated: Bool) {
        
        
        
    }
    
    @IBAction func onClick(_sender : UIButton?){
        
        if _sender?.tag == 1{
            
            
        }else if _sender?.tag == 2{
            
            // View deals here
            
            println("add")
            
        }else if _sender?.tag == 3{
            
            // Edit profile here
            println("add")
            
        }
    }
    
    
    @IBAction func pickerSelected(sender: AnyObject) {
        
        if sender.tag == 0 {
            ActionSheetStringPicker.showPickerWithTitle("Month", rows: months as [AnyObject], initialSelection: 1, doneBlock: {
                picker, value, index in
                
                self.monthsBtn.setTitle("\(index)", forState: UIControlState.Normal)
                
                println("value = \(value)")
                println("index = \(index)")
                println("picker = \(picker)")
                return
                }, cancelBlock: { ActionStringCancelBlock in return }, origin: sender)
            
        }
        
    }
    
    
    func updateAnalytics(){
        
        //Update numbers here
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "toProfile") {
            var svc = segue.destinationViewController as! RegisterRestaurantVC2;
            
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

