//
//  Profile.swift
//  Saloof
//
//  Created by Nazir Shuqair on 8/7/15.
//  Copyright (c) 2015 SNASTek. All rights reserved.
//

import UIKit
import MobileCoreServices
import ActionSheetPicker_3_0
import RealmSwift
import AssetsLibrary

class ProfileVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
    @IBOutlet weak var RestaurantTitleLabel: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    var newMedia: Bool?
    var newImage = false
    var validImage = false
    var compressedImgData = NSData()
    @IBOutlet weak var contactField: UITextField!
    //Category
    @IBOutlet weak var catButton: UIButton!
    var categories:FoodCategories = FoodCategories()
    var categoryArray = []
    // Price Tier
    @IBOutlet weak var priceControls: UISegmentedControl!
    var selectedPrice = 1
    var validPrice = false
    //Hours
    @IBOutlet weak var weekdayO: UIButton!
    @IBOutlet weak var weekdayC: UIButton!
    @IBOutlet weak var weekendO: UIButton!
    @IBOutlet weak var weekendC: UIButton!
    let prefs: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    var weekdayString = ""
    var weekendString = ""
    
    var profileImg = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage(named: "navBarLogo")
        navigationItem.titleView = UIImageView(image: image)
        
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
        categoryArray = categories.loadCategories()
        
        loadElements()
        
    }
    
    func loadElements(){
        
        var realm = Realm()
        
        var data = Realm().objectForPrimaryKey(ProfileModel.self, key: prefs.stringForKey("restID")!)
        
        RestaurantTitleLabel.text = data?.restaurantName
        var name = data?.contactName
        contactField.text = name
        var category = data?.category
        catButton.setTitle(category, forState: UIControlState.Normal)
        var price = data?.priceTier
        priceControls.selectedSegmentIndex = price!
        var week = data?.weekdayHours
        var weekend = data?.weekendHours
        parseHours(week!, weekend: weekend!)
        imgView.image = profileImg
        
    }
    
    func parseHours(week: String, weekend: String){
        var delimiter = "-"
        if week != "" {
            let trimmedString = week.stringByReplacingOccurrencesOfString(" ", withString: "")
            var weekO = trimmedString.componentsSeparatedByString(delimiter)[0]
            var weekCIndex = trimmedString.rangeOfString("-", options: .BackwardsSearch)?.endIndex
            var weekC = trimmedString.substringFromIndex(weekCIndex!)
            weekdayO.setTitle("\(weekO)", forState: .Normal)
            weekdayC.setTitle("\(weekC)", forState: .Normal)
        }
        if weekend != ""{
            let trimmedString = weekend.stringByReplacingOccurrencesOfString(" ", withString: "")
            var weeknO = trimmedString.componentsSeparatedByString(delimiter)[0]
            var weeknCIndex = trimmedString.rangeOfString("-", options: .BackwardsSearch)?.endIndex
            var weeknC = trimmedString.substringFromIndex(weeknCIndex!)
            weekendO.setTitle("\(weeknO)", forState: .Normal)
            weekendC.setTitle("\(weeknC)", forState: .Normal)
        }
        
    }
    
    
    func saveData(){
        var validation = Validation()
        var category = self.catButton.titleLabel?.text
        var wkO = self.weekdayO.titleLabel?.text
        var wkC = self.weekdayC.titleLabel?.text
        var wknO = self.weekendO.titleLabel?.text
        var wknC = self.weekendC.titleLabel?.text
        weekdayString = validation.formatHours(wkO!, weekC: wkC!, weekendO: wknO!, weekendC: wknC!).weekdayHours
        weekendString = validation.formatHours(wkO!, weekC: wkC!, weekendO: wknO!, weekendC: wknC!).weekendHours

        var realm = Realm()
        var data = Realm().objectForPrimaryKey(ProfileModel.self, key: prefs.stringForKey("restID")!)
        uploadChanges(data!)
        realm.write({
            data?.contactName = self.contactField.text
            data?.category = category!
            data?.priceTier = self.priceControls.selectedSegmentIndex + 1
            if wkO != nil{
                data?.weekdayO = wkO!
            }
            if wkC != nil{
                data?.weekdayC = wkC!
            }
            if wknO != nil{
                data?.weekendO = wknO!
            }
            if wknC != nil{
                data?.weekendC = wknC!
            }
            data?.weekdayHours = self.weekdayString
            data?.weekendHours = self.weekendString
            
        })
    }
    
    func uploadChanges(data : ProfileModel){
        
        var contactNameUpdate = data.contactName
        var imageUpated = data.imgUri
        var streetUpdate = data.streetAddress
        var cityUpdate = data.city
        var zipcodeUpdate = data.zipcode
        var phoneNumUpdate = data.phoneNum
        var priceUpdate = data.priceTier
        var restaurantNameUpdate = data.restaurantName
        var latUpdate = data.lat
        var lngUpate = data.lng
        var selectedCat = catButton.titleLabel?.text
        var categoryUpdate = selectedCat!
        var websiteUpdate = data.website
        
        if count(contactField.text) > 0 {
            contactNameUpdate = contactField.text
        }
        if selectedPrice > 0 {
            priceUpdate = selectedPrice
        }
        
        var restID = prefs.stringForKey("restID")!
        println(priceUpdate)
        
        var containerView = CreateActivityView.createView(UIColor.blackColor(), frame: self.view.frame)
        var aIView = CustomActivityView(frame: CGRect (x: 0, y: 0, width: 100, height: 100), color: UIColor.whiteColor(), size: CGSize(width: 100, height: 100))
        aIView.center = containerView.center
        containerView.addSubview(aIView)
        containerView.center = self.view.center
        self.view.addSubview(containerView)
        aIView.startAnimation()
        
        var call = "{\"VenueId\":\"\(restID)\",\"ContactName\":\"\(contactNameUpdate)\",\"StreetName\":\"\(streetUpdate)\",\"City\":\"\(cityUpdate)\",\"State\":\"DC\",\"ZipCode\":\"\(zipcodeUpdate)\",\"PhoneNumber\":\"\(phoneNumUpdate)\",\"PriceTier\":\(priceUpdate),\"WeekdaysHours\":\"\(weekdayString)\",\"WeekEndHours\":\"\(weekendString)\",\"RestaurantName\":\"\(restaurantNameUpdate)\",\"Lat\":\"\(latUpdate)\",\"Lng\":\"\(lngUpate)\",\"CategoryName\":\"\(categoryUpdate)\",\"Website\":\"\(websiteUpdate)\",\"ImageName\":\"\(imageUpated)\"}"
        
        var token = prefs.stringForKey("TOKEN")
        
        if Reachability.isConnectedToNetwork(){
            var authentication = AuthenticationCalls()
            authentication.registerRestaurant(call, token: token!){ result in
                if result {
                    if self.newImage{
                        self.newImage = false
                        var apiCall = APICalls()
                        apiCall.uploadImg(self.compressedImgData, imgName: imageUpated){ result in
                            dispatch_async(dispatch_get_main_queue()){
                                aIView.stopAnimation()
                                var alertView:UIAlertView = UIAlertView()
                                alertView.title = "Saved"
                                alertView.delegate = self
                                alertView.addButtonWithTitle("OK")
                                alertView.show()
                                containerView.removeFromSuperview()
                            }
                        }
                    }else{
                        dispatch_async(dispatch_get_main_queue()){
                            aIView.stopAnimation()
                            var alertView:UIAlertView = UIAlertView()
                            alertView.title = "Saved"
                            alertView.delegate = self
                            alertView.addButtonWithTitle("OK")
                            alertView.show()
                            containerView.removeFromSuperview()
                        }
                    }
                    
                }
            }
        }else{
            var alertView:UIAlertView = UIAlertView()
            alertView.title = "Offline!"
            alertView.message = "Looks like you're offline, your changes have been saved locally, please try uploading later"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        }
    }
    
    override func viewDidLayoutSubviews() {
        imgView.layer.masksToBounds = false
        imgView.layer.borderColor = UIColor.blackColor().CGColor
        imgView.layer.cornerRadius = imgView.frame.height/2
        imgView.clipsToBounds = true
    }
    
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    @IBAction func onClick(_sender:UIButton){
        
        if _sender.tag == 0{
            
            //save here
            self.saveData()
            
        }else if _sender.tag == 1{
            self.startImageAction()
        }else if _sender.tag == 2{
            // Log out here
            self.signOff()
        }
        
    }
    
    @IBAction func pickerSelected(sender: AnyObject) {
        
        if sender.tag == 4 {
            ActionSheetStringPicker.showPickerWithTitle("Category", rows: categoryArray as [AnyObject], initialSelection: 1, doneBlock: {
                picker, value, index in
                
                self.catButton.setTitle("\(index)", forState: UIControlState.Normal)
                
                println("value = \(value)")
                println("index = \(index)")
                println("picker = \(picker)")
                return
                }, cancelBlock: { ActionStringCancelBlock in return }, origin: sender)
            
        }else if sender.tag < 4{
            
            ActionSheetStringPicker.showPickerWithTitle("Time", rows: ["12am", "1am", "2am", "3am", "4am", "5am", "6am", "7am", "8am", "9am", "10am", "11am", "12pm", "1pm", "2pm", "3pm", "4pm", "5pm", "6pm", "7pm", "8pm", "9pm", "10pm", "11pm"] as [AnyObject], initialSelection: 1, doneBlock: {
                picker, value, index in
                
                if sender.tag == 0 {
                    self.weekdayO.setTitle("\(index)", forState: UIControlState.Normal)
                }else if sender.tag == 1{
                    self.weekdayC.setTitle("\(index)", forState: UIControlState.Normal)
                }else if sender.tag == 2{
                    self.weekendO.setTitle("\(index)", forState: UIControlState.Normal)
                }else if sender.tag == 3{
                    self.weekendC.setTitle("\(index)", forState: UIControlState.Normal)
                }
                
                println("value = \(value)")
                println("index = \(index)")
                println("picker = \(picker)")
                return
                }, cancelBlock: { ActionStringCancelBlock in return }, origin: sender)
            
        }
        
        
    }
    
    
    @IBAction func priceControl(sender: AnyObject) {
        
        switch sender.selectedSegmentIndex{
        case 0:
            selectedPrice = 1
        case 1:
            selectedPrice = 2
        case 2:
            selectedPrice = 3
        case 3:
            selectedPrice = 4
        default:
            break;
        }
    }
    
    
    func signOff(){
        prefs.setObject(nil, forKey: "TOKEN")
        prefs.setObject(nil, forKey: "restID")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // Camera methods
    
    func startImageAction(){
        // Take picture here
        
        //Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: "Upload a picture", message: "It can be of your restaurant or a of a dish off your menu", preferredStyle: .ActionSheet)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        //Create and add first option action
        let takePictureAction: UIAlertAction = UIAlertAction(title: "Take Picture", style: .Default) { action -> Void in
            //Code for launching the camera goes here
            if UIImagePickerController.isSourceTypeAvailable(
                UIImagePickerControllerSourceType.Camera) {
                    
                    let imagePicker = UIImagePickerController()
                    
                    imagePicker.delegate = self
                    imagePicker.sourceType =
                        UIImagePickerControllerSourceType.Camera
                    imagePicker.mediaTypes = [kUTTypeImage as NSString]
                    imagePicker.allowsEditing = false
                    
                    self.presentViewController(imagePicker, animated: true,
                        completion: nil)
                    self.newMedia = true
            }
            
        }
        actionSheetController.addAction(takePictureAction)
        //Create and add a second option action
        let choosePictureAction: UIAlertAction = UIAlertAction(title: "Choose From Camera Roll", style: .Default) { action -> Void in
            //Code for picking from camera roll goes here
            if UIImagePickerController.isSourceTypeAvailable(
                UIImagePickerControllerSourceType.SavedPhotosAlbum) {
                    let imagePicker = UIImagePickerController()
                    
                    imagePicker.delegate = self
                    imagePicker.sourceType =
                        UIImagePickerControllerSourceType.PhotoLibrary
                    imagePicker.mediaTypes = [kUTTypeImage as NSString]
                    imagePicker.allowsEditing = false
                    self.presentViewController(imagePicker, animated: true,
                        completion: nil)
                    self.newMedia = false
            }
        }
        
        actionSheetController.addAction(choosePictureAction)
        
        //We need to provide a popover sourceView when using it on iPad
        //actionSheetController.popoverPresentationController?.sourceView = sender as! UIView;
        
        //Present the AlertController
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        if mediaType.isEqualToString(kUTTypeImage as! String) {
            let image = info[UIImagePickerControllerOriginalImage]
                as! UIImage
            imgView.image = image
            compressedImgData = UIImageJPEGRepresentation(image, 1)
            var ratio: CGFloat = 0.5
            var attempts = 6
            println("Initial imageSize: \(compressedImgData.length)")
            while compressedImgData.length > 80000 && attempts > 0 {
                attempts = attempts - 1
                ratio = ratio * 0.5
                println("image Size before compression: \(compressedImgData.length)")
                compressedImgData = UIImageJPEGRepresentation(image, ratio)
                println("image Size after compression: \(compressedImgData.length) with ratio: \(ratio)")
            }
            println("final image size: \(compressedImgData.length)")
            
            newImage = true
            validImage = true
            
            if (newMedia == true) {
                var imageData = UIImageJPEGRepresentation(imgView.image, 0.6)
                var compressedJPGImage = UIImage(data: imageData)
                ALAssetsLibrary().writeImageToSavedPhotosAlbum(compressedJPGImage!.CGImage, orientation: ALAssetOrientation(rawValue: compressedJPGImage!.imageOrientation.rawValue)!,
                    completionBlock:{ (path:NSURL!, error:NSError!) -> Void in
                       
                })
                
            } else if mediaType.isEqualToString(kUTTypeMovie as! String) {
                // Code to support video here
            }
        }
        
        // Will use this when we save pics from web
        
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo:UnsafePointer<Void>) {
        
        if error != nil {
            let alert = UIAlertController(title: "Save Failed",
                message: "Failed to save image",
                preferredStyle: UIAlertControllerStyle.Alert)
            
            let cancelAction = UIAlertAction(title: "OK",
                style: .Cancel, handler: nil)
            
            alert.addAction(cancelAction)
            self.presentViewController(alert, animated: true,
                completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}
