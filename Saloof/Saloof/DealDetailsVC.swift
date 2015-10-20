//
//  DealDetailsVC.swift
//  Saloof
//
//  Created by Nazir Shuqair on 7/18/15.
//  Copyright (c) 2015 SNASTek. All rights reserved.
//

import UIKit
import RealmSwift

class DealDetailsVC: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    //View labels
    @IBOutlet weak var dealImgView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    //Fields
    @IBOutlet weak var tierLabel: UILabel!
    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var descTF: UITextView!
    @IBOutlet weak var textCounterLabel: UILabel!
    @IBOutlet weak var valueTF: UITextField!
    @IBOutlet weak var timeController: UISegmentedControl!
    
    @IBOutlet weak var deleteBtn: UIButton!
    var tier = 0
    var dealTitle = ""
    var desc = ""
    var value = 0.0
    var hours = 1
    var dealID = ""
    var editingMode = false
    var deleteEnabled = true
    var img = UIImage()
    
    var realm = try! Realm()
    var apiCall = APICalls()
    let prefs: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    
    // View to indicate selected hour button
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        dealImgView.image = img
        dealImgView.layer.masksToBounds = false
        dealImgView.layer.borderColor = UIColor.blackColor().CGColor
        dealImgView.layer.cornerRadius = dealImgView.frame.height/2
        dealImgView.clipsToBounds = true
        
        
        if editingMode{
            if deleteEnabled{
                deleteBtn.hidden = false
            }else{
                deleteBtn.hidden = true
            }
        }else{
            deleteBtn.hidden = true
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if hours > 0 {
            timeController.selectedSegmentIndex = hours - 1
            timeLabel.text =  "\(hours)hr limit"
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage(named: "navBarLogo")
        navigationItem.titleView = UIImageView(image: image)
        
        // View to indicate selected hour button -- update color to black
        titleTF.delegate = self
        valueTF.delegate = self
        
        if editingMode{
            tierLabel.text = "Tier \(tier)"
            titleTF.text = dealTitle
            titleLabel.text = dealTitle
            if desc != "" {
                descTF.text = desc
                descLabel.text = desc
            }
            valueTF.text = String(stringInterpolationSegment: value)
            valueLabel.text = "$\(String(stringInterpolationSegment: value)) value"
        }else{
            tierLabel.text = "They are going to love this..."
            if !editingMode{
                //Adding placeholder to text view
                descTF.delegate = self
                descTF.text = "e.g. Get 10% off of any medium size drink when you buy a launch meal"
                descTF.textColor = UIColor.whiteColor()
            }
        }
        
        titleTF.attributedPlaceholder = NSAttributedString(string:"Deal's Title",
            attributes:[NSForegroundColorAttributeName: UIColor(red:0.93, green:0.93, blue:0.93, alpha:0.85)])
        valueTF.attributedPlaceholder = NSAttributedString(string:"Deal's Value",
            attributes:[NSForegroundColorAttributeName: UIColor(red:0.93, green:0.93, blue:0.93, alpha:0.85)])
        // Addes guesture to hide keyboard when tapping on the view
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    
    
    func textViewDidBeginEditing(textView: UITextView) {
        navigationController?.navigationBarHidden = true
        descTF.text = ""
    }
    
    func textViewDidChange(textView: UITextView) {
        navigationController?.navigationBarHidden = true
        let currentCount = 140 - descTF.text.characters.count
        if currentCount <= 0{
            descTF.text = descTF.text.substringToIndex(descTF.text.endIndex.predecessor())
        }
        self.descLabel.text = descTF.text
        self.textCounterLabel.text = "\(currentCount) characters left"
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        navigationController?.navigationBarHidden = false
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        navigationController?.navigationBarHidden = true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 0{
            titleLabel.text = titleTF.text
        }else if textField.tag == 1{
            valueLabel.text = "$\(valueTF.text) value"
        }
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        navigationController?.navigationBarHidden = false
        if textField.tag == 0{
            titleLabel.text = titleTF.text
        }else if textField.tag == 1{
            valueLabel.text = "$\(valueTF.text) value"
        }
    }
    
    // Mark# OnClick Method
    
    @IBAction func onClick(_sender : UIButton?){
        
        if _sender?.tag == 0{
            // Save here
            saveDeal()
        }else if _sender?.tag == 1{
            deleteDeal()
        }
    }
    
    @IBAction func timeLimitSelector(sender: AnyObject) {
        
        switch sender.selectedSegmentIndex{
        case 0:
            updateHours(1)
        case 1:
            updateHours(2)
        case 2:
            updateHours(3)
        default:
            break;
        }
    }
    
    func updateHours(incomingHour: Int){
        hours = incomingHour
        timeLabel.text = "\(hours)hr limit"
    }
    
    func saveDeal(){
        
        if titleTF.text!.characters.count > 0 && descTF.text.characters.count > 0 && valueTF!.text!.characters.count > 0 && hours > 0 {
            
            // save here
            let deal = BusinessDeal()
            deal.title = titleTF.text!
            deal.desc = descTF.text
            deal.value = Double(valueTF.text!)!
            //deal.value = (valueTF.text as String).doubleValue
            deal.timeLimit = hours
            deal.restaurantID = prefs.stringForKey("restID")!
            print(deal.restaurantID)
            deal.isActive = true
            if editingMode {
                deal.id = dealID
            }else{
                deal.id = NSUUID().UUIDString
                print("creation id:\(deal.id)")
            }
            
            let call = "{\"DealId\":\"\(deal.id)\",\"VenueId\":\"\(deal.restaurantID)\",\"DealTitle\":\"\(deal.title)\",\"DealDescription\":\"\(deal.desc)\",\"DealValue\":\(deal.value),\"TimeLimit\":\(deal.timeLimit), \"Active\":true}"
            apiCall.uploadDeal(call, token: prefs.stringForKey("TOKEN")!)
            realm.write{
                self.realm.add(deal, update: self.editingMode)
            }
            
            let count = prefs.integerForKey("DealCount")
            prefs.setInteger(count + 1, forKey: "DealCount")
            prefs.synchronize()
            print("saved")
            
            let refreshAlert = UIAlertController(title: "Saved", message: "Deal has been saved", preferredStyle: UIAlertControllerStyle.Alert)
            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: {(action: UIAlertAction!) in
                self.navigationController?.popViewControllerAnimated(true)
            }))
            self.presentViewController(refreshAlert, animated: true, completion: nil)
            
            
        }else  if titleTF.text!.characters.count < 1{
            titleTF.attributedPlaceholder = NSAttributedString(string:"Title Required",
                attributes:[NSForegroundColorAttributeName: UIColor(red:0.93, green:0.93, blue:0.93, alpha:0.85)])
            alertUser("No Title", message: "Please give your deal a title")
        }else if descTF.text.characters.count < 1 {
            descTF.text = "Description Required"
            alertUser("No Description", message: "Please give your deal a description")
            descTF.textColor = UIColor.lightGrayColor()
        }else if valueTF.text!.characters.count < 1 {
            valueTF.attributedPlaceholder = NSAttributedString(string:"Value Required",
                attributes:[NSForegroundColorAttributeName: UIColor(red:0.93, green:0.93, blue:0.93, alpha:0.85)])
            alertUser("No Value", message: "Please give your deal a value")

        }
        
    }
    
    func deleteDeal(){
        
        if dealID != ""{
            
            let venueID = prefs.stringForKey("restID")!
            let call = "{\"DealId\":\"\(dealID)\",\"VenueId\":\"\(venueID)\",\"DealTitle\":\"\(dealTitle)\",\"DealDescription\":\"\(desc)\",\"DealValue\":\(value),\"TimeLimit\":\(hours), \"Active\":false}"
            apiCall.uploadDeal(call, token: prefs.stringForKey("TOKEN")!)
            
            let refreshAlert = UIAlertController(title: "Are you sure?", message: "Are you sure you want to delete this deal", preferredStyle: UIAlertControllerStyle.Alert)
            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: {(action: UIAlertAction) in
                let dealToDelete = self.realm.objectForPrimaryKey(BusinessDeal.self, key: self.dealID)
                
                self.realm.write{
                    self.realm.delete(dealToDelete!)
                }
                let count = self.prefs.integerForKey("DealCount")
                self.prefs.setInteger(count - 1, forKey: "DealCount")
                self.prefs.synchronize()
                
                self.navigationController?.popViewControllerAnimated(true)
            }))
            refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: {(action: UIAlertAction) in
            }))
            self.presentViewController(refreshAlert, animated: true, completion: nil)
        }
    }
    
    func alertUser(title: String, message: String) {
        let alertView:UIAlertView = UIAlertView()
        alertView.title = title
        alertView.message = message
        alertView.delegate = self
        alertView.addButtonWithTitle("OK")
        alertView.show()
    }

    
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
