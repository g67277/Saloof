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
    var selectedPrice = 0
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
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
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
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
       /* if textField.tag == 0{
            println(count(phoneNumField.text))
            
            if count(phoneNumField.text) > 10{
                //var updatedInput = count(descTF.text)
                phoneNumField.text = phoneNumField.text.substringToIndex(phoneNumField.text.endIndex.predecessor())
            }
        }
        return true*/
        if textField.tag == 0 {
            var newString = (phoneNumField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
            var components = newString.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
            
            var decimalString = "".join(components) as NSString
            var length = decimalString.length
            if length == 0 || length > 10 || length > 11 {
                var newLength = (phoneNumField.text as NSString).length + (string as NSString).length - range.length as Int
                return (newLength > 10) ? false : true
            }
            var index = 0 as Int
            var formattedString = NSMutableString()
            
            if (length - index) > 3 {
                var areaCode = decimalString.substringWithRange(NSMakeRange(index, 3))
                formattedString.appendFormat("(%@) ", areaCode)
                index += 3
            }
            if length - index > 3 {
                var prefix = decimalString.substringWithRange(NSMakeRange(index, 3))
                formattedString.appendFormat("%@-", prefix)
                index += 3
            }
            var remainder = decimalString.substringFromIndex(index)
            formattedString.appendString(remainder)
            phoneNumField.text = formattedString as String
            return false
        } else {
            return true
        }

    }
    
    @IBAction func onClick(_sender:UIButton){
        
        if _sender.tag == 5{
            
            //sign up here
            self.continueRegistration()
            
        } else if _sender.tag == 10 {
            if continueSession{
                navigationController?.popViewControllerAnimated(true)
            }
        }
        
    }
    
    @IBAction func returnToReg2 (segue:UIStoryboardSegue) {
        
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
            selectedPrice = 0
        case 1:
            selectedPrice = 1
        case 2:
            selectedPrice = 2
        case 3:
            selectedPrice = 3
        default:
            break;
        }
    }
    
    // Registration Call Methods
    
    
    
    func continueRegistration(){
        
       // runTestingMethod()
        
        var restaurantName = restNameField.text
        var street = streetField.text
        var city = cityField.text
        var zipcode = zipecodeField.text
        var phoneNum = phoneNumField.text
        var website = websiteField.text
        var selectedCategory = catButton.titleLabel?.text as String!
        var price = priceControls.selectedSegmentIndex
        var wkO = weekdayO.titleLabel?.text
        var wkC = weekdayC.titleLabel?.text
        var wknO = weekendO.titleLabel?.text
        var wknC = weekendC.titleLabel?.text
        var weekdayString = validation.formatHours(wkO!, weekC: wkC!, weekendO: wknO!, weekendC: wknC!).weekdayHours
        var weekendString = validation.formatHours(wkO!, weekC: wkC!, weekendO: wknO!, weekendC: wknC!).weekendHours
        
        println("Lat: \(validatedlat), Lng: \(validatedlng)")
        
        if validation.validateInput(restaurantName, check: 1, title: "Too Short", message: "Please enter a valid Restaurant name")
            && validation.validateAddress(street, city: city, zipcode: zipcode, lat: self.validatedlat, lng: self.validatedlng).valid
            //&& validation.validatePhone(phoneNumField.text, check: 10, title: "Invalid Number", message: "Please enter a valid Phone number")
            && validation.validatePhone(phoneNumField.text, check: 14, title: "Invalid Number", message: "Please enter a valid Phone number")
            && validation.category(selectedCategory!){
                
                //call = "\"StreetName\":\"\(street)\",\"City\":\"\(city)\",\"State\":\"DC\",\"ZipCode\":\"\(zipcode)\",\"PhoneNumber\":\"\(phoneNum)\",\"PriceTier\":\(price),\"WeekdaysHours\":\"10am - 10pm\",\"WeekEndHours\":\"10am - 10pm\",\"RestaurantName\":\"\(restaurantName)\",\"Lat\":\"\(validatedlat)\",\"Lng\":\"\(validatedlng)\",\"CategoryName\":\"\(selectedCategory)\",\"Website\":\"\(website)\"}"
                call = "\"StreetName\":\"\(street)\",\"City\":\"\(city)\",\"State\":\"DC\",\"ZipCode\":\"\(zipcode)\",\"PhoneNumber\":\"\(phoneNum)\",\"PriceTier\":\(price),\"WeekdaysHours\":\"10AM-10PM\",\"WeekEndHours\":\"10AM-12AM\",\"RestaurantName\":\"\(restaurantName)\",\"Lat\":\"\(validatedlat)\",\"Lng\":\"\(validatedlng)\",\"CategoryName\":\"\(selectedCategory)\",\"Website\":\"\(website)\""
                println(call)
                self.saveData(restaurantName, street: street, city: city, zipcode: zipcode.toInt()!, phoneNum: phoneNum, website: website, category: selectedCategory!, price: price, wkO: wkO!, wkC: wkC!, wknO: wknO!, wknC: wknC!, weekdayString: weekdayString, weekendString: weekendString)
        }else {
            errorLabel.hidden = false
        }
        
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
            var svc = segue.destinationViewController as! RegisterRestaurantVC3;
            
            svc.callPart1 = call
            if continueSession{
                svc.continueSession = true
            }
        }
    }
    
    func saveData(name: String, street: String, city: String, zipcode: Int, phoneNum: String, website: String, category: String, price: Int, wkO: String, wkC: String, wknO: String, wknC: String, weekdayString: String, weekendString: String){
        
        var model = ProfileModel()
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
        
        var realm = Realm()
        realm.write({
            realm.add(model, update: true)
        })
        
        self.performSegueWithIdentifier("toReg3", sender: nil)
        
    }
    
    func findCoorinates(formattedAddress: String) {
        
        var geocoder = CLGeocoder()
        geocoder.geocodeAddressString(formattedAddress, completionHandler: {(placemarks: [AnyObject]!, error: NSError!) -> Void in
            if let placemark = placemarks?[0] as? CLPlacemark {
                var location:CLLocation = placemark.location
                var coordinates:CLLocationCoordinate2D = location.coordinate
                self.validatedlat = coordinates.latitude
                self.validatedlng = coordinates.longitude
            }
        })
        
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
