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
    @IBOutlet weak var numberOfDeals: UILabel!
    @IBOutlet weak var monthsBtn: UIButton!
    
    @IBOutlet weak var profileImgView: UIImageView!
    var savedDealsArray = Realm().objects(BusinessDeal)
    let realm = Realm()
    let apiCall = APICalls()
    
    typealias filteredData = (Int, Int)
    var selectedDeals : [filteredData] = []
    var swappedDeals : [filteredData] = []
    var availableCredits = 0
    var selectedMonth = 0
    var defaultTimeZoneStr = 0
    var dealsCount = 0
    
    // holds all the months to display in selector
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    
    let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage(named: "navBarLogo")
        navigationItem.titleView = UIImageView(image: image)
        
        let date = NSDate();
        var formatter = NSDateFormatter();
        formatter.dateFormat = "M";
        defaultTimeZoneStr = formatter.stringFromDate(date).toInt()!
        monthsBtn.setTitle(months[defaultTimeZoneStr - 1], forState: UIControlState.Normal)
        selectedMonth = defaultTimeZoneStr - 1
        updateImg()
    }
    
    override func viewWillAppear(animated: Bool) {
        updateDisplay()
    }
    
    func updateImg(){
        
        var data = Realm().objectForPrimaryKey(ProfileModel.self, key: prefs.stringForKey("restID")!)
        var imgID = data?.imgUri
        var url = "http://ec2-52-2-195-214.compute-1.amazonaws.com/Images/\(imgID!).jpg"
        if data != nil{
            dealsCount = data!.dealsCount
        }else{
            dealsCount = 0
        }
        if imgID != nil{
            let imageUrl = NSURL(string: url)
            if let data = NSData(contentsOfURL: imageUrl!){
                
                let venueImage = UIImage(data: data)
                profileImgView.image = venueImage
            }
        }else{
            //display default image here
        }
    }
    
    func parseSummery(json: JSON){
        
        selectedDeals.removeAll(keepCapacity: true)
        swappedDeals.removeAll(keepCapacity: true)
        var returnedData = json.array!
        for deal in returnedData{
            var selectedDeal = filteredData(deal["TotalDealsPurchased"].int!, deal["Month"].int!)
            var swappedDeal = filteredData(deal["TotalDealsSwapped"].int!, deal["Month"].int!)
            selectedDeals.append(selectedDeal)
            swappedDeals.append(swappedDeal)
            availableCredits = deal["CreditAvailable"].int!
        }
        
        filterData(defaultTimeZoneStr)
    }
    
    func filterData(month: Int){
        dispatch_async(dispatch_get_main_queue()){
            
            if self.selectedDeals.count > 0 {
                var total = 0
                for item in self.selectedDeals{
                    if item.1 == month {
                        total = total + item.0
                    }
                }
                self.dealsSelectedLabel.text = "\(total)"
            }else{
                self.dealsSelectedLabel.text = "0"
            }
            
            if self.swappedDeals.count > 0 {
                var total = 0
                for item in self.swappedDeals{
                    if item.1 == month {
                        total = total + item.0
                    }
                }
                self.dealsSwapedLabel.text = "\(total)"
            }else{
                self.dealsSwapedLabel.text = "0"
            }
        }
    }
    
    func updateDisplay(){
        
        var data = Realm().objectForPrimaryKey(ProfileModel.self, key: prefs.stringForKey("restID")!)
        restaurantNameLabel.text = data?.restaurantName
        updateImg()
        
        if Reachability.isConnectedToNetwork(){
            apiCall.getBalance(prefs.stringForKey("restID")!, token: prefs.stringForKey("TOKEN")!){ result in
                
                self.parseSummery(result)
                dispatch_async(dispatch_get_main_queue()){
                    self.numberOfDeals.text = "\(self.dealsCount)"
                    if self.availableCredits > 0 {
                        self.creditBalanceLabel.text = "\(self.availableCredits)C"
                    }else{
                        self.creditBalanceLabel.text = "No Credits"
                    }
                }
            }
        }else{
            numberOfDeals.text = "Offline"
            self.creditBalanceLabel.text = "Offline"
            self.dealsSelectedLabel.text = "Offline"
            self.dealsSwapedLabel.text = "Offline"

        }
        
    }
    
    override func viewDidLayoutSubviews() {
        profileImgView.layer.masksToBounds = false
        profileImgView.layer.borderColor = UIColor.blackColor().CGColor
        profileImgView.layer.cornerRadius = profileImgView.frame.height/2
        profileImgView.clipsToBounds = true
    }
    
    @IBAction func onClick(_sender : UIButton?){
        
        if _sender?.tag == 1{
            
        }else if _sender?.tag == 2{
            
        }else if _sender?.tag == 3{
        }
    }
    
    
    @IBAction func pickerSelected(sender: AnyObject) {
        
        if sender.tag == 0 {
            ActionSheetStringPicker.showPickerWithTitle("Month", rows: months as [AnyObject], initialSelection: selectedMonth, doneBlock: {
                picker, value, index in
                self.monthsBtn.setTitle("\(index)", forState: UIControlState.Normal)
                self.selectedMonth = value
                self.filterData(value + 1)
                println("value = \(value)")
                println("index = \(index)")
                println("picker = \(picker)")
                return
                }, cancelBlock: { ActionStringCancelBlock in return }, origin: sender)
        }
    }
  
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "toProfile") {
            var svc = segue.destinationViewController as! ProfileVC
            if profileImgView.image != nil{
                svc.profileImg = profileImgView.image!
            }
            
        }else if segue.identifier == "toDealList" {
            var svc = segue.destinationViewController as! DealsVC;
            if profileImgView.image != nil{
                svc.defaultImg = profileImgView.image!
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

