//
//  VenueDealsVC.swift
//  Saloof
//
//  Created by Angela Smith on 7/22/15.
//  Copyright (c) 2015 SNASTek. All rights reserved.
//

import UIKit
import RealmSwift
import CoreLocation
import SwiftyJSON

class VenueDealsVC: UIViewController,  CLLocationManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate,  UIPickerViewDataSource, UIPickerViewDelegate {
    
    // View properties
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var bestButton: UIButton!
    @IBOutlet var oldestButton: UIButton!
    @IBOutlet var collectionCardView: UIView!
    @IBOutlet var singleDealView: UIView!
    @IBOutlet var pageController: UIPageControl!
    
    @IBOutlet var saveSwapButton: UIButton!
    
    // singleDealOutlets
    @IBOutlet weak var singleLocationTitle: UILabel!
    @IBOutlet weak var singleLocationImage: UIImageView!
    @IBOutlet weak var singleDealTitle: UILabel!
    @IBOutlet weak var singleDealDesc: UILabel!
    @IBOutlet weak var singleDealValue: UILabel!
    
    @IBOutlet var cardButtonsView: UIView!
    @IBOutlet var indicatorView: UIView!
    var searchBarButton: UIBarButtonItem!
    var cancelButton: UIBarButtonItem!
    let activityIndicator = CustomActivityView(frame: CGRect (x: 0, y: 0, width: 100, height: 100), color: UIColor(red:0.98, green:0.39, blue:0.2, alpha:1), size: CGSize(width: 100, height: 100))
    
    // Search
    @IBOutlet weak var searchDisplayOverview: UIView!
    @IBOutlet var burgerTextField: UITextField!
    @IBOutlet var searchView: UIView!
    @IBOutlet var priceView: UIView!
    @IBOutlet var priceTextField: UITextField!
    @IBOutlet var searchPickerView: UIView!
    @IBOutlet var pickerSpinnerView: UIView!
    @IBOutlet var searchPicker: UIPickerView!
    
    // Search Properties
    var searchPrice : Bool = false
    var searchQuery : Bool = false
    var searchString = ""
    var offsetCount: Int = 0
    var pickerDataSource = ["Any","$", "$$", "$$$", "$$$$"];
    
    // top deal timer
    @IBOutlet weak var timeLimitLabel: TTCounterLabel!
    let realm = Realm()
    var plistObjects: [AnyObject] = []
    // get access to all the current deals
    var validDeals2 = Realm().objects(Venue)
    var validDeals = Realm().objects(VenueDeal)
    var haveItems: Bool = false;
    var loadSingleDeal: Bool = false
    // Location objects
    var locationManager : CLLocationManager!
    var venueLocations : [AnyObject] = []
    var venueItems : [[String: AnyObject]]?
    var currentLocation: CLLocation!
    
    var setUpForSaved: Bool = false
    var setUpForDefault: Bool = false
    var topDealReached = false
    var currentDealIndex = 0
    // used in the featured section as to not display non-qualifying deals
    var topBidIndex = 0
    // Holds the last deal processesed for comparison
    var lastDealRestId = ""
    var currentSavedDealId = ""
    var singleDeal = VenueDeal()
    var savedDeal = SavedDeal()
    var topDeal = VenueDeal()
    var selectedDeal: VenueDeal?
    let dealList = List<VenueDeal>()
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    //Testing
    let prefs: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var userLocation = ""
    var token = ""
    
    /* -----------------------  INITIAL LOAD  METHODS --------------------------- */
    
    override func viewWillAppear(animated: Bool) {
        // delete expired deals
        var expiredDeals = Realm().objects(VenueDeal).filter("\(Constants.dealValid) = \(2)")
        realm.write {
            self.realm.delete(expiredDeals)
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if !loadSingleDeal {
            searchBarButton = UIBarButtonItem(image: UIImage(named: "searchButton"), style: .Plain, target: self, action: "shouldOpenSearch")
            cancelButton = UIBarButtonItem(image: UIImage(named: "closeIcon"), style: .Plain, target: self, action: "shouldCloseSearch")
            self.navigationItem.setRightBarButtonItem(searchBarButton, animated: false)
            
            burgerTextField.attributedPlaceholder = NSAttributedString(string:"Burger",
                attributes:[NSForegroundColorAttributeName: UIColor(red:0.93, green:0.93, blue:0.93, alpha:0.85)])
            
            priceTextField.attributedPlaceholder = NSAttributedString(string:"$",
                attributes:[NSForegroundColorAttributeName: UIColor(red:0.93, green:0.93, blue:0.93, alpha:0.85)])
            searchView.roundCorners(.AllCorners, radius: 14)
            priceView.roundCorners(.AllCorners, radius: 14)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        token = prefs.stringForKey("TOKEN")!
        if loadSingleDeal {
            
            // Set up view for a single deal
            collectionCardView.hidden = true
            cardButtonsView.hidden = true
            singleDealView.hidden = false
            
            // see if it is for the saved deal or a default deal
            if setUpForSaved {
                setUpSaveSwapButton()
                saveSwapButton.enabled = false
            }
            else if setUpForDefault {
                setUpDefaultDeal()
            }
        } else {
            // start getting new deals for collection view
            singleDealView.hidden = true
            collectionCardView.hidden = false
            cardButtonsView.hidden = false
            locationManager = CLLocationManager()
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
            initialDeals()
        }
        
    }
    
    func setButtonTitle (title: String) {
        saveSwapButton.setTitle(title, forState: UIControlState.Normal)
        saveSwapButton.setTitle(title, forState: UIControlState.Selected)
    }
    
    
    func setUpDefaultDeal() {
        // set up view for a default deal
        singleLocationTitle.text = " from \(singleDeal.venue.name)"
        if singleDeal.venue.hasImage {
            singleLocationImage.image = singleDeal.venue.image
        } else {
            // set up default image
            singleLocationImage.image = UIImage(named: "redHen")
        }
        singleDealTitle.text = singleDeal.name
        singleDealDesc.text = singleDeal.desc
        // Set up the value
        let valueFloat:Float = singleDeal.value, valueFormat = ".2"
        singleDealValue.text = "$\(valueFloat.format(valueFormat)) value"
    }
    
    func setUpSaveSwapButton () {
        // set up view for a default deal
        singleLocationTitle.text = " from \(savedDeal.venue.name)"
        if savedDeal.venue.hasImage {
            singleLocationImage.image = savedDeal.venue.image
        } else {
            // set up default image
            singleLocationImage.image = UIImage(named: "redHen")
        }
        singleDealTitle.text = savedDeal.name
        singleDealDesc.text = savedDeal.desc
        // Set up the value
        let valueFloat:Float = savedDeal.value, valueFormat = ".2"
        singleDealValue.text = "$\(valueFloat.format(valueFormat)) value"
        setSavedDealTimer(savedDeal)
    }
    
    
    // -------------------------  BUTTON ACTIONS  ------------------------
    
    @IBAction func userPressedSaveSwapButton(sender: UIButton) {
        
        // if viewing non current saved deal, see if we have a saved one
        checkForPreviouslySavedDeal()
        
    }
    
    func checkForPreviouslySavedDeal() {
        // check if user already has a saved deal
        var currentSavedDeal = realm.objects(SavedDeal).first
        if (currentSavedDeal != nil) {
            println("The user has a saved deal")
            // make sure the deal is not expired
            let valid = checkDealIsValid(currentSavedDeal!)
            if valid {
                println("The user has a saved deal")
                // display an alert requesting if they want to switch
                let alertController = UIAlertController(title: "Swap Deals?", message: "Would you like to swap \(currentSavedDeal?.name) for \(selectedDeal?.name)", preferredStyle: .Alert)
                // Add button action to swap
                let cancelSwap = UIAlertAction(title: "Cancel", style: .Default, handler: {
                    (action) -> Void in
                })
                let swapDeals = UIAlertAction(title: "Swap", style: .Default, handler: {
                    (action) -> Void in
                    // Swap deals
                    self.realm.write {
                        self.realm.delete(currentSavedDeal!)
                    }
                    self.saveNewDeal()
                })
                alertController.addAction(cancelSwap)
                alertController.addAction(swapDeals)
                presentViewController(alertController, animated: true, completion: nil)
            } else {
                // deleted old deal, save new one
                realm.write {
                    self.realm.delete(currentSavedDeal!)
                }
                println("Deleted expired deal and saving new one")
                // save this deal as the saved deal
                saveNewDeal()
            }
        } else {
            println("Setting a new saved deal")
            // save this deal as the saved deal
            saveNewDeal()
        }
    }
    
    func checkDealIsValid (savedDeal: SavedDeal) -> Bool {
        // we need to check the date
        let expiresTime = savedDeal.expirationDate
        // see how much time has lapsed
        var compareDates: NSComparisonResult = NSDate().compare(expiresTime)
        if compareDates == NSComparisonResult.OrderedAscending {
            // the deal has not expired yet
            println("This deal is still good")
            return true
        } else {
            //the deal has expired
            println("This deal has expired, deleting it")
            realm.write {
                self.realm.delete(savedDeal)
            }
            return false
        }
    }
    
    func saveNewDeal () {
        if let deal: VenueDeal = selectedDeal {
            currentSavedDealId = deal.id
            let newDeal = SavedDeal()
            newDeal.name = deal.name
            newDeal.desc = deal.desc
            newDeal.tier = deal.tier
            newDeal.timeLimit = deal.timeLimit
            newDeal.expirationDate = deal.expirationDate
            newDeal.value = deal.value
            newDeal.venue = deal.venue
            var venueId = "\(newDeal.venue.identifier).\(newDeal.tier)"
            newDeal.id = venueId
            realm.write {
                self.realm.create(SavedDeal.self, value: newDeal, update: true)
            }
            // alert user deal was saved
            var alertView:UIAlertView = UIAlertView()
            alertView.title = "Deal Saved!"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
            // and change the button
            saveSwapButton.enabled = false
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onButtonSelect(sender: UIButton) {
        if sender.tag == 0 {
            bestButton.selected = true
            oldestButton.selected = false
            pageController.currentPage = 0
            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.Left, animated: true)
            let deal: VenueDeal = dealList[indexPath.row]
            // set the timer to this deal
            setDealTimer(deal)
            
        }  else if sender.tag == 2 {
            bestButton.selected = false
            oldestButton.selected = true
            println(pageController.currentPage)
            pageController.currentPage = dealList.count - 1
            let indexPath = NSIndexPath(forRow: Int(dealList.count-1), inSection: 0)
            collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.Left, animated: true)
            let deal: VenueDeal = dealList[indexPath.row]
            // set the timer to this deal
            setDealTimer(deal)
        }
    }
    
    
    //  -------------------------------------  LOADING DEALS  ------------------------------------------------
//    func loadSaloofData () {
//        let saloofUrl = NSURL(string: "http://www.justwalkingonwater.com/json/venueResponse.json")!
//        let response = NSData(contentsOfURL: saloofUrl)!
//        let json: AnyObject? = (NSJSONSerialization.JSONObjectWithData(response,
//            options: NSJSONReadingOptions(0),
//            error: nil) as! NSDictionary)["response"]
//        
//        if let object: AnyObject = json {
//            haveItems = true
//            var groups = object["groups"] as! [AnyObject]
//            //  get array of items
//            var venues = groups[0]["items"] as! [AnyObject]
//            for item in venues {
//                // get the venue
//                if let venue = item["venue"] as? [String: AnyObject] {
//                    // get each deal
//                    let venueJson = JSON(venue)
//                    // Parse the JSON file using SwiftlyJSON
//                    JSONParser.parseJSON(venueJson, source: Constants.sourceTypeSaloof)
//                }
//            }
//            // FINISHED CREATING DATA OBJECTS
//            // get a list of all deal objects in Realm
//            validDeals = Realm().objects(VenueDeal)
//            // Sort all deals by value
//            let sortedDeals = Realm().objects(VenueDeal).filter("\(Constants.dealValid) = \(1)").sorted("value", ascending:true)
//            validDeals = sortedDeals
//            //println("Sorted Deals from ParseJSON \(sortedDeals)")
//            biddingStart()
//        }
//    }
    
    
    
    func biddingStart(){
        if currentDealIndex < validDeals.count{
            // we have more deals to sort
            if lastDealRestId != "" {
                
                if lastDealRestId != validDeals[currentDealIndex].venue.identifier {
                    // Update lastDeal to hold the current restaurant id
                    lastDealRestId = validDeals[currentDealIndex].venue.identifier
                    // Adding the new restaurant to the top of the array as it has a higher value
                    dealList.insert(validDeals[currentDealIndex], atIndex: 0)
                    delayReload()
                    // match the topBidIndex with current RestaurantIndex... This only happenes here.
                    topBidIndex = currentDealIndex
                    currentDealIndex = currentDealIndex + 1
                    
                    delayLoad()
                }else{
                    // increment current index to skip this deal, topBid is not updated so that we don't display this
                    // bad deal in the featured section
                    currentDealIndex = currentDealIndex + 1
                    biddingStart()
                }
                
            }else{
                //println("restaurant Name: \(validDeals[currentDealIndex].name), deal tier: \(validDeals[currentDealIndex].tier), deal value: \(validDeals[currentDealIndex].value)")
                println(currentDealIndex)
                println(validDeals[0])
                lastDealRestId = validDeals[currentDealIndex].venue.identifier
                dealList.insert(validDeals[currentDealIndex], atIndex: 0)
                currentDealIndex = currentDealIndex + 1
                delayLoad()
            }
            
        } else {
            
            // Once we are done with the array, hide the indicator, set the topDealReached, display the top
            // deal in the featured section
            topDealReached = true
            selectedDeal = dealList[0]
            setDealTimer(selectedDeal!)
            if currentSavedDealId != "" {
                saveSwapButton.enabled = (currentSavedDealId == selectedDeal?.id) ? false : true
            }
        }
        
    }
    
    /* -----------------------  DELAY  METHODS --------------------------- */
    
    // This method creates a break between the tableview updating and returning a new deal to add to the view
    func delayLoad() {
        let timeDelay = Double(arc4random_uniform(1500000000) + 100000000)
        var dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(timeDelay))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            self.biddingStart()
            self.collectionView.reloadData()
        })
        
    }
    
    // This delay starts the spinner giving the appearance a new deal is loading, then removes it and updates the list with a new deal
    func delayReload() {
        let timeDelay = Double(arc4random_uniform(1500000000) + 300000000)
        var dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(timeDelay))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            self.topDeal = self.validDeals[self.topBidIndex]
            self.collectionView.reloadData()
        })
        
    }
    
    //  ------------------------ COLLECTIONVIEW METHODS  ----------------------------------
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // 1
        // Return the number of sections
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dealList.count
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("dealCell", forIndexPath: indexPath) as! DealCardCell
        let deal: VenueDeal = dealList[indexPath.row]
        cell.setUpVenueDeal(deal)
        pageController.numberOfPages = dealList.count
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        // get the height of the view
        var height: CGFloat = collectionCardView.bounds.height * 0.75
        var width = height * 1.9
        
        return CGSizeMake(width, height)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
        
        var cell : UICollectionViewCell = collectionView.cellForItemAtIndexPath(indexPath)!
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        let deal: VenueDeal = dealList[indexPath.row]
        // set the timer to this deal
        setDealTimer(deal)
        selectedDeal = deal
        // set the timer to this deal
        setDealTimer(selectedDeal!)
        if currentSavedDealId != "" {
            saveSwapButton.enabled = (currentSavedDealId == selectedDeal?.id) ? false : true
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        let one = Double(scrollView.contentOffset.x)
        let two = Double(self.view.frame.width)
        let result = one / two
        
        if result != 0{
            if (0.0 != fmodf(Float(result), 1.0)){
                pageController.currentPage = Int(Float(result) + 1)
                let indexPath = NSIndexPath(forRow: Int(Float(result) + 1), inSection: 0)
                collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.Left, animated: true)
                selectedDeal = dealList[indexPath.row]
                // set the timer to this deal
                setDealTimer(selectedDeal!)
                if currentSavedDealId != "" {
                    saveSwapButton.enabled = (currentSavedDealId == selectedDeal?.id) ? false : true
                }
            }else{
                pageController.currentPage = Int(result)
                let indexPath = NSIndexPath(forRow: Int(result), inSection: 0)
                collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.Left, animated: true)
                selectedDeal = dealList[indexPath.row]
                // set the timer to this deal
                setDealTimer(selectedDeal!)
                if currentSavedDealId != "" {
                    saveSwapButton.enabled = (currentSavedDealId == selectedDeal?.id) ? false : true
                }
            }
        }
    }
    
    func setDealTimer(deal: VenueDeal) {
        // Set up the timer countdown label
        let now = NSDate()
        let expires = deal.expirationDate
        let calendar = NSCalendar.currentCalendar()
        let datecomponenets = calendar.components(NSCalendarUnit.CalendarUnitSecond, fromDate: now, toDate: expires, options: nil)
        let seconds = datecomponenets.second * 1000
        if seconds > 0 {
            timeLimitLabel.countDirection = 1
            timeLimitLabel.startValue = UInt64(seconds)
            timeLimitLabel.start()
        }
        // println("Seconds: \(seconds) times 1000")
        if seconds <= 0 {
            timeLimitLabel.stop()
            // set this deal to delete and the view to reload
        }
    }
    
    func setSavedDealTimer(deal: SavedDeal) {
        // Set up the timer countdown label
        let now = NSDate()
        let expires = deal.expirationDate
        let calendar = NSCalendar.currentCalendar()
        let datecomponenets = calendar.components(NSCalendarUnit.CalendarUnitSecond, fromDate: now, toDate: expires, options: nil)
        let seconds = datecomponenets.second * 1000
        // println("Seconds: \(seconds) times 1000")
        timeLimitLabel.countDirection = 1
        timeLimitLabel.startValue = UInt64(seconds)
        timeLimitLabel.start()
        if seconds <= 0 {
            timeLimitLabel.stop()
            // set this deal to delete and the view to reload
        }
    }
    
    // ------------------- USER LOCATION PERMISSION REQUEST  ----------------------
    
    func showErrorAlert(error: NSError) {
        let alertController = UIAlertController(title: "Our Bad!", message:"Sorry, but we are having trouble finding where you are right now. Maybe try again later.", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Ok", style: .Default, handler: {
            (action) -> Void in
        })
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        showErrorAlert(error)
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        locationManager.stopUpdatingLocation()
        // if we dont' have any locations, get some
        if haveItems == false {
            println("We don't have any deals yet")
            
            
            println("Have location, gather local deals")
            //loadSaloofData()
            // get  local deals
            
            let location = self.locationManager.location
            userLocation = "lat=\(location.coordinate.latitude)&lng=\(location.coordinate.longitude)"
            
        }
    }
    
    func initialDeals(){
    
        dealList.removeAll()
        // delete any current venues
        var pulledVenues = Realm().objects(VenueDeal)
        if pulledVenues.count < 1{
            realm.write {
                self.realm.delete(pulledVenues)
            }
        }
        
        // Start getting the users location
        locationManager.startUpdatingLocation()
        
        if APICalls.getLocalDeals(token, location: userLocation) {
            self.refreshDataArray()
        } else {
            println("Unable to retrieved deals from Saloof")
        }
    }
    
    func refreshDataArray(){
        
        println("Retrieved deals from Saloof")
        haveItems = true
        //FINISHED CREATING DATA OBJECTS
        //get a list of all deal objects in Realm
        validDeals = Realm().objects(VenueDeal)
        
        println("We have \(validDeals.count) returned deals")
        println("We have \(validDeals.count) returned deals")
        //Sort all deals by value
        let sortedDeals = Realm().objects(VenueDeal).filter("\(Constants.dealValid) = \(1)").sorted("value", ascending:true)
        validDeals = sortedDeals
        //println("Sorted Deals from ParseJSON \(sortedDeals)")
        biddingStart()
        //pullLocalDeals()
    }
    
    //  ------------------  SEARCH TAGS AND PRICE PICKER METHODS ----------------------------
    

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count;
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return pickerDataSource[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        searchQuery = false
        searchPrice = true
        switch row {
        case 0:
            priceTextField.text = "";
            searchString = ""
        case 1:
            priceTextField.text = "$";
            searchString = "1"
        case 2:
            priceTextField.text = "$$";
            searchString = "2"
        case 3:
            priceTextField.text = "$$$";
            searchString = "3"
        case 4:
            priceTextField.text = "$$$$";
            searchString = "4"
        default:
            priceTextField.text = ""
            searchString = ""
        }
        // reload search
        didSelectPricePoint()
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = pickerDataSource[row]
        var myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 14.0)!,NSForegroundColorAttributeName:UIColor.whiteColor()])
        return myTitle
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int,
        reusingView view: UIView!) -> UIView {
            var pickerLabel = view as! UILabel!
            if view == nil {  //if no label there yet
                pickerLabel = UILabel()
            }
            let titleData = pickerDataSource[row]
            let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 18.0)!,NSForegroundColorAttributeName:UIColor.whiteColor()])
            pickerLabel!.attributedText = myTitle
            pickerLabel.textAlignment = .Center
            return pickerLabel
            
    }
    
    //size the components of the UIPickerView
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return pickerSpinnerView.bounds.width
    }
    
    func didSelectPricePoint() {
        UIView.transitionWithView(searchPickerView, duration: 0.2, options:
            .CurveEaseOut | .TransitionCrossDissolve, animations: {
                //...animations
            }, completion: {_ in
                self.searchPickerView.hidden = true
                UIView.transitionWithView(self.searchDisplayOverview, duration: 0.2, options:
                    .CurveEaseOut | .TransitionCrossDissolve, animations: {
                        //...animations
                    }, completion: {_ in
                        self.resetView(true)
                        
                })
        })
    }
    
    func resetView(shouldSearch: Bool) {
        activityIndicator.startAnimation()
        searchDisplayOverview.hidden = true
        searchPrice = shouldSearch
        self.navigationItem.setRightBarButtonItem(searchBarButton, animated: false)
        if shouldSearch {
            // reload search
           pullNewSearchResults(true)
            
        }
    }
    
    
    func shouldOpenSearch () {
        searchDisplayOverview.hidden = false
        self.navigationItem.setRightBarButtonItem(cancelButton, animated: true)
        
    }
    
    func shouldCloseSearch () {
        searchDisplayOverview.hidden = true
        searchQuery = false;
        searchPrice = false
        burgerTextField.text = ""
        burgerTextField.editing
        self.navigationItem.setRightBarButtonItem(searchBarButton, animated: true)
        
    }
    
    func pullNewSearchResults (pricePoint: Bool) {
        
        dealList.removeAll()
        // delete any current venues
        var pulledVenues = Realm().objects(VenueDeal)
        if pulledVenues.count < 1{
            realm.write {
                self.realm.delete(pulledVenues)
            }
        }
        
        // Start getting the users location
        locationManager.startUpdatingLocation()
        
        // reset values
        lastDealRestId = ""
        topBidIndex = 0
        currentDealIndex = 0
        topDealReached = false
        
        if pricePoint{
            var call = "priceTier=\(searchString)&\(userLocation)"
            println(call)
            APICalls.getLocalDealsByCategory(token, call: call){ result in
                if result{
                    self.refreshDataArray()
                    self.activityIndicator.stopAnimation()
                }
            }
        }else{
            var formattedSearch = searchString.stringByReplacingOccurrencesOfString(" ", withString: "%20", options: NSStringCompareOptions.LiteralSearch, range: nil)
            println(userLocation)
            var call = "category=\(formattedSearch)&\(userLocation)"
            println(call)

            APICalls.getLocalDealsByCategory(token, call: call){ result in
                if result{
                    self.refreshDataArray()
                    self.activityIndicator.stopAnimation()
                }
            }
        }
        // pull new venues
        //loadSaloofData()
        searchDisplayOverview.hidden = true
    }

    
    //  ---------------------  UITEXTFIELD DELEGATE  ---------------------------------
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.tag == 4 {
            textField.resignFirstResponder()
            // display the picker view
            searchPickerView.hidden = false
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        println("Textfield returned")
        textField.endEditing(true)
        //self.view.endEditing(true)
        self.navigationItem.setRightBarButtonItem(searchBarButton, animated: true)
        // see which text field was entered
        if textField.tag == 3 {
            // Search
            if textField.text != "" {
                searchString = textField.text
                searchQuery = true
                searchPrice = false
                textField.text = ""
                pullNewSearchResults(false)
            }
        }
        return false
    }

}
