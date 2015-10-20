//
//  SignupVC.swift
//  authentication test
//
//  Created by Nazir Shuqair on 7/14/15.
//  Copyright (c) 2015 SNASTek. All rights reserved.
//

import UIKit
import MobileCoreServices
import ActionSheetPicker_3_0
import CoreLocation
import RealmSwift


class RegisterRestaurantVC2: UIViewController, UITextFieldDelegate {
    
    //Restaurant Name Field
    @IBOutlet weak var restNameField: UITextField!
    //Category
    @IBOutlet weak var catButton: UIButton!
    var categories:FoodCategories = FoodCategories()
    var categoryArray = []
    // Address
    @IBOutlet weak var streetField: UITextField!
    @IBOutlet weak var cityField: UITextField!
    @IBOutlet weak var zipecodeField: UITextField!
    var formattedAddress = ""
    var validAddress = false
    var validatedlat = 0.0
    var validatedlng = 0.0
    // Phone Number
    @IBOutlet weak var phoneNumField: UITextField!
    var validPhone = false
    @IBOutlet weak var websiteField: UITextField!
    var validWeb = false
    // Price Tier
    @IBOutlet weak var priceControls: UISegmentedControl!
    var selectedPrice = 1
    var validPrice = false
    //Hours
    @IBOutlet weak var weekdayO: UIButton!
    @IBOutlet weak var weekdayC: UIButton!
    @IBOutlet weak var weekendO: UIButton!
    @IBOutlet weak var weekendC: UIButton!
    //Register/Edit button
    @IBOutlet var errorLabel: UILabel!
    
    var continueSession = false
    
    let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    let validation = Validation()
    var call = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // Addes guesture to hide keyboard when tapping on the view
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
        phoneNumField.delegate = self
        phoneNumField.tag = 0
        zipecodeField.delegate = self
        zipecodeField.tag = 1
        categoryArray = categories.loadCategories()
        
        restNameField.attributedPlaceholder = NSAttributedString(string:"Restaurant Name",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        streetField.attributedPlaceholder = NSAttributedString(string:"Street Address",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        cityField.attributedPlaceholder = NSAttributedString(string:"City",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        zipecodeField.attributedPlaceholder = NSAttributedString(string:"Postal Code",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        phoneNumField.attributedPlaceholder = NSAttributedString(string:"Phone Number",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        websiteField.attributedPlaceholder = NSAttributedString(string:"Website",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])

    }
    
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        // Validates address and retrives coordinates
        if textField.tag == 1{
            findCoorinates(("\(streetField.text), \(cityField.text), \(zipecodeField.text)"))
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        errorLabel.hidden = true
        errorLabel.text = "Please fill all the required fields"
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == phoneNumField {
            //println("formatting phone field")
            let newString = (phoneNumField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
            let components = newString.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
            
            let decimalString = components.joinWithSeparator("") as NSString
            let length = decimalString.length
            if length == 0 || length > 10 || length > 11 {
                let newLength = (phoneNumField.text! as NSString).length + (string as NSString).length - range.length as Int
                return (newLength > 10) ? false : true
            }
            var index = 0 as Int
            let formattedString = NSMutableString()
            
            if (length - index) > 3 {
                let areaCode = decimalString.substringWithRange(NSMakeRange(index, 3))
                formattedString.appendFormat("(%@) ", areaCode)
                index += 3
            }
            if length - index > 3 {
                let prefix = decimalString.substringWithRange(NSMakeRange(index, 3))
                formattedString.appendFormat("%@-", prefix)
                index += 3
            }
            let remainder = decimalString.substringFromIndex(index)
            formattedString.appendString(remainder)
            phoneNumField.text = formattedString as String
            return false
        } else if textField == zipecodeField {
            // limit the zip code to 5 digits
            //println("Limiting the zip code length to 5 digits")
            let newLength = textField.text!.utf16.count + string.utf16.count - range.length
            return newLength <= 5
            
        } else {
            return true
        }

    }
    
    @IBAction func onClick(_sender:UIButton){
        
        if _sender.tag == 5{
            
            //sign up here
            self.checkFields()
            //self.continueRegistration()
            
        } else if _sender.tag == 10 {
            if continueSession{
                navigationController?.popViewControllerAnimated(true)
            }
        }
        
    }
    
    @IBAction func returnToReg2 (segue:UIStoryboardSegue) {
        
    }
    
    @IBAction func pickerSelected(sender: AnyObject) {
        errorLabel.hidden = true
        errorLabel.text = "Please fill all the required fields"
        if sender.tag == 4 {
            ActionSheetStringPicker.showPickerWithTitle("Category", rows: categoryArray as [AnyObject], initialSelection: 1, doneBlock: {
                picker, value, index in
                
                self.catButton.setTitle("\(index)", forState: UIControlState.Normal)
                
                print("value = \(value)", terminator: "")
                print("index = \(index)")
                print("picker = \(picker)")
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
                
                print("value = \(value)", terminator: "")
                print("index = \(index)", terminator: "")
                print("picker = \(picker)", terminator: "")
                return
                }, cancelBlock: { ActionStringCancelBlock in return }, origin: sender)
            
        }
        
        
    }
    
    @IBAction func priceControl(sender: AnyObject) {
        errorLabel.hidden = true
        errorLabel.text = "Please fill all the required fields"
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
    
    // Registration Call Methods
    
    
    
    func continueRegistration(){
        
       // runTestingMethod()
        let restaurantName = restNameField.text
        let street = streetField.text
        let city = cityField.text
        let zipcode = zipecodeField.text
        let phoneNum = phoneNumField.text
        let website = websiteField.text
        let selectedCategory = catButton.titleLabel?.text as String!
        let price = priceControls.selectedSegmentIndex + 1
        let wkO = weekdayO.titleLabel?.text
        let wkC = weekdayC.titleLabel?.text
        let wknO = weekendO.titleLabel?.text
        let wknC = weekendC.titleLabel?.text
        let weekdayString = validation.formatHours(wkO!, weekC: wkC!, weekendO: wknO!, weekendC: wknC!).weekdayHours
        let weekendString = validation.formatHours(wkO!, weekC: wkC!, weekendO: wknO!, weekendC: wknC!).weekendHours
        
        print("Lat: \(validatedlat), Lng: \(validatedlng)", terminator: "")
        call = "\"StreetName\":\"\(street)\",\"City\":\"\(city)\",\"State\":\"DC\",\"ZipCode\":\"\(zipcode)\",\"PhoneNumber\":\"\(phoneNum)\",\"PriceTier\":\(price),\"WeekdaysHours\":\"\(weekdayString)\",\"WeekEndHours\":\"\(weekendString)\",\"RestaurantName\":\"\(restaurantName)\",\"Lat\":\"\(validatedlat)\",\"Lng\":\"\(validatedlng)\",\"CategoryName\":\"\(selectedCategory)\",\"Website\":\"\(website)\""
        print(call, terminator: "")
        self.saveData(restaurantName!, street: street!, city: city!, zipcode: Int(zipcode!)!, phoneNum: phoneNum!, website: website!, category: selectedCategory!, price: price, wkO: wkO!, wkC: wkC!, wknO: wknO!, wknC: wknC!, weekdayString: weekdayString, weekendString: weekendString)
        /*
        if validation.validateInput(restaurantName, check: 1, title: "Too Short", message: "Please enter a valid Restaurant name")
            && validation.validateAddress(street, city: city, zipcode: zipcode, lat: self.validatedlat, lng: self.validatedlng).valid
            //&& validation.validatePhone(phoneNumField.text, check: 10, title: "Invalid Number", message: "Please enter a valid Phone number")
            && validation.validatePhone(phoneNumField.text, check: 14, title: "Invalid Number", message: "Please enter a valid Phone number")
            && validation.category(selectedCategory!){

                call = "\"StreetName\":\"\(street)\",\"City\":\"\(city)\",\"State\":\"DC\",\"ZipCode\":\"\(zipcode)\",\"PhoneNumber\":\"\(phoneNum)\",\"PriceTier\":\(price),\"WeekdaysHours\":\"\(weekdayString)\",\"WeekEndHours\":\"\(weekendString)\",\"RestaurantName\":\"\(restaurantName)\",\"Lat\":\"\(validatedlat)\",\"Lng\":\"\(validatedlng)\",\"CategoryName\":\"\(selectedCategory)\",\"Website\":\"\(website)\""
                println(call)
                self.saveData(restaurantName, street: street, city: city, zipcode: zipcode.toInt()!, phoneNum: phoneNum, website: website, category: selectedCategory!, price: price, wkO: wkO!, wkC: wkC!, wknO: wknO!, wknC: wknC!, weekdayString: weekdayString, weekendString: weekendString)
        }else {
            errorLabel.hidden = false
        }*/
        
    }
    
    func checkFields() {
        if Reachability.isConnectedToNetwork(){
            let restaurantName = restNameField.text
            let website = websiteField.text
            
            // check the name
            if validation.validateInput(restaurantName!, check: 1, title: "Too Short", message: "Please enter a valid Restaurant name") {
                // then phone number
                if validation.validatePhone(phoneNumField.text!, check: 14, title: "Invalid Number", message: "Please enter a valid Phone number") {
                    // then site
                    let prefix = "http://" + website!
                    validation.shouldValidateWebsiteUrl(prefix, completion: { result in
                        if result {
                            dispatch_async(dispatch_get_main_queue()){
                                self.validateRemainingFields()
                            }
                        } else {
                            dispatch_async(dispatch_get_main_queue()){
                                print("website is invalid", terminator: "")
                                self.errorLabel.hidden = false
                                self.errorLabel.text = "Please enter a valid website"
                                self.alertUser("Invalid Website", message: "Please enter a valid website")
                            }
                        }
                    })
                } else {
                    self.errorLabel.hidden = false
                    self.errorLabel.text = "Please enter a valid phone number"
                }
            } else {
                self.errorLabel.hidden = false
                self.errorLabel.text = "Please enter a valid Restaurant name"
            }

        } else {
            alertUser("No Network", message: "Please check your network connection")
        }
    }
    
    func validateRemainingFields() {
        let street = streetField.text
        let city = cityField.text
        let zipcode = zipecodeField.text
        let selectedCategory = catButton.titleLabel?.text as String!
        // check address
        if self.validation.validateAddress(street!, city: city!, zipcode: zipcode!, lat: self.validatedlat, lng: self.validatedlng).valid {
                // check categorry
            if self.validation.category(selectedCategory!){
                print("All fields are valid", terminator: "")
                continueRegistration()
            } else {
                print("fields are invalid", terminator: "")
                self.errorLabel.hidden = false
                self.errorLabel.text = "Please select a category"
            }
        } else {
            self.errorLabel.hidden = false
            self.errorLabel.text = "Please enter a valid location address"
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
    
    func runTestingMethod(){
        
        //restNameField.text = "Nazir"
        streetField.text = "43124 Shadow Ter"
        cityField.text = "leesburg"
        zipecodeField.text = "20176"
        phoneNumField.text = "1234567890"
        websiteField.text = "weofijewof.com"
        //catButton.setTitle("burger", forState: .Normal)
        priceControls.selectedSegmentIndex = 2
        weekdayO.setTitle("10am", forState: .Normal)
        weekdayC.setTitle("10am", forState: .Normal)
        weekendO.setTitle("10am", forState: .Normal)
        weekendC.setTitle("10am", forState: .Normal)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "toReg3") {
            let svc = segue.destinationViewController as! RegisterRestaurantVC3;
            
            svc.callPart1 = call
            if continueSession{
                svc.continueSession = true
            }
        }
    }
    
    func saveData(name: String, street: String, city: String, zipcode: Int, phoneNum: String, website: String, category: String, price: Int, wkO: String, wkC: String, wknO: String, wknC: String, weekdayString: String, weekendString: String){
        
        let model = ProfileModel()
        model.restaurantName = name
        model.streetAddress = street
        model.city = city
        model.zipcode = zipcode
        model.phoneNum = phoneNum
        model.website = website
        model.category = category
        model.priceTier = price
        model.weekdayO = wkO
        model.weekdayC = wkC
        model.weekendO = wknO
        model.weekendC = wknC
        model.weekdayHours = weekdayString
        model.weekendHours = weekendString
        model.id = "will change"
        
        let realm = try! Realm()
        realm.write({
            realm.add(model, update: true)
        })
        
        self.performSegueWithIdentifier("toReg3", sender: nil)
        
    }
    
    func findCoorinates(formattedAddress: String) {
        
        var geocoder = CLGeocoder()
        geocoder.geocodeAddressString(formattedAddress) { (placemarks, error) -> Void in
            if let placemark = placemarks?[0] as! CLPlacemark {
                var location:CLLocation = placemark.location!
                var coordinates:CLLocationCoordinate2D = location.coordinate
                self.validatedlat = coordinates.latitude
                self.validatedlng = coordinates.longitude
            }
        }
        /*geocoder.geocodeAddressString(formattedAddress, completionHandler: {(placemarks: [AnyObject]!, error: NSError!) -> Void in
            if let placemark = placemarks?[0] as? CLPlacemark {
                var location:CLLocation = placemark.location!
                var coordinates:CLLocationCoordinate2D = location.coordinate
                self.validatedlat = coordinates.latitude
                self.validatedlng = coordinates.longitude
            }
        })*/
        
    }
    
    override func viewWillAppear(animated: Bool) {
        // Hide the navigation bar to display the full location image
        self.navigationController?.navigationBarHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
