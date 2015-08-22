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

class VenueDealsVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate,  UIPickerViewDataSource, UIPickerViewDelegate {
    
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
    let actIndicator = CustomActivityView(frame: CGRect (x: 0, y: 0, width: 80, height: 80), color: UIColor.whiteColor(), size: CGSize(width: 80, height: 80))
    var actContainer = CreateActivityView.createView(UIColor.clearColor(), frame: UIScreen.mainScreen().bounds)
    
    
    // Search
    @IBOutlet weak var searchDisplayOverview: UIView!
    @IBOutlet var burgerTextField: UITextField!
    @IBOutlet var searchView: UIView!
    @IBOutlet var priceView: UIView!
    @IBOutlet var priceTextField: UITextField!
    //@IBOutlet var searchPickerView: UIView!
    //@IBOutlet var pickerSpinnerView: UIView!
    //@IBOutlet var searchPicker: UIPickerView!
    
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
    var manager: OneShotLocationManager?
    var location: CLLocation!
    var venueLocations : [AnyObject] = []
    var venueItems : [[String: AnyObject]]?
    var currentLocation: CLLocation!
    var haveLocation: Bool = false
    
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
            getCurrentSavedDealId()
        }
    }
    
    override func viewDidLayoutSubviews() {
        searchView.roundCorners(.AllCorners, radius: 14)
        priceView.roundCorners(.AllCorners, radius: 14)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var pickerView = UIPickerView()
        pickerView.delegate = self
        priceTextField.inputView = pickerView
        
        let image = UIImage(named: "navBarLogo")
        var homeButton =  UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        homeButton.frame = CGRectMake(0, 0, 100, 40) as CGRect
        homeButton.setImage(image, forState: UIControlState.Normal)
        homeButton.addTarget(self, action: Selector("returnHome"), forControlEvents: UIControlEvents.TouchUpInside)
        navigationItem.titleView = homeButton

        // set up for the actifity indicator
        actIndicator.center = CGPoint(x: self.actContainer.center.x, y: self.actContainer.center.y - 40)
        self.actContainer.addSubview(actIndicator)
        self.actContainer.center = self.view.center
        token = prefs.stringForKey("TOKEN")!
        if loadSingleDeal {
            
            // Set up view for a single deal
            collectionCardView.hidden = true
            cardButtonsView.hidden = true
            singleDealView.hidden = false
            
            // see if it is for the saved deal or a default deal
            if setUpForSaved {
                setUpSavedDeal()
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
            // Get location and deals
            setUpForInitialDeals()
        }
    }
    
    func returnHome() {
        self.performSegueWithIdentifier("returnHomeFromDeals", sender: self)
    }
    
    func setButtonTitle (title: String) {
        saveSwapButton.setTitle(title, forState: UIControlState.Normal)
        saveSwapButton.setTitle(title, forState: UIControlState.Selected)
    }
    
    func getCurrentSavedDealId() {
        var currentSavedDeal = realm.objects(SavedDeal).first
        if (currentSavedDeal != nil) {
            println("The user has a saved deal")
            // make sure the deal is not expired
            let valid = checkDealIsValid(currentSavedDeal!)
            if valid {
                currentSavedDealId = currentSavedDeal!.dealId
            }
        }
    }
    
    func setUpDefaultDeal() {
        // set up view for a default deal
        singleLocationTitle.text = " from \(singleDeal.name)"
        singleLocationImage.setImageCacheWithAddress(singleDeal.venueImageUrl, placeHolderImage: UIImage (named: "placeholder")!)
        singleDealTitle.text = singleDeal.name
        singleDealDesc.text = singleDeal.desc
        // Set up the value
        let valueFloat:Float = singleDeal.value, valueFormat = ".2"
        singleDealValue.text = "$\(valueFloat.format(valueFormat)) value"
    }
    
    func setUpSavedDeal () {
        // set up view for a default deal
        singleLocationTitle.text = " from \(savedDeal.name)"
        singleLocationImage.setImageCacheWithAddress(singleDeal.venueImageUrl, placeHolderImage: UIImage (named: "placeholder")!)
        singleDealTitle.text = savedDeal.name
        singleDealDesc.text = savedDeal.desc
        // Set up the value
        let valueFloat:Float = savedDeal.value, valueFormat = ".2"
        singleDealValue.text = "$\(valueFloat.format(valueFormat)) value"
        setSavedDealTimer(savedDeal)
    }
    
    
    // -------------------------  BUTTON ACTIONS  ------------------------
    
    // this method handles the price picker view to make sure the curser is not displayed
    @IBAction func openPricePicker(sender: AnyObject) {
        priceTextField.tintColor = UIColor.clearColor()
        println("pressed price")
        if priceTextField.isFirstResponder() {
            println("is responder")
            priceTextField.resignFirstResponder()
        } else {
            println("becomming responder")
            priceTextField.becomeFirstResponder()
        }
    }

    
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
                let alertController = UIAlertController(title: "Swap Deals?", message: "Would you like to swap \(currentSavedDeal!.name) for \(selectedDeal!.name)", preferredStyle: .Alert)
                // Add button action to swap
                let cancelSwap = UIAlertAction(title: "Cancel", style: .Default, handler: {
                    (action) -> Void in
                })
                let swapDeals = UIAlertAction(title: "Swap", style: .Default, handler: {
                    (action) -> Void in
                    // Swap deals - increase the old deal credits, and decrease the current
                    APICalls.shouldSwapCreditForDeal(currentSavedDeal?.id as String!, token: self.token, newDeal: self.selectedDeal?.id as String!, completion:{ result in
                        if result {
                            dispatch_async(dispatch_get_main_queue()){
                                println("Favorited this venue")
                                self.removeCurrentLocalNotification(currentSavedDeal!.dealId)
                                self.realm.write {
                                    self.realm.delete(currentSavedDeal!)
                                }
                                self.saveNewDeal(true)
                            }
                        } else {
                            dispatch_async(dispatch_get_main_queue()){
                                println("unable to decrement Deal credits")
                            }
                            
                        }
                    })
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
                saveNewDeal(false)
            }
        } else {
            println("Setting a new saved deal")
            // save this deal as the saved deal
            saveNewDeal(false)
        }
    }
    
    func checkDealIsValid (savedDeal: SavedDeal) -> Bool {
        // we need to check the date
        let expiresTime = savedDeal.expirationDate
        // see how much time has lapsed
        var compareDates: NSComparisonResult = NSDate().compare(expiresTime)
        if compareDates == NSComparisonResult.OrderedAscending {
            // the deal has not expired yet
            return true
        } else {
            //the deal has expired
            realm.write {
                self.realm.delete(savedDeal)
            }
            return false
        }
    }
    
    func saveNewDeal (didSwap: Bool) {
        if let deal: VenueDeal = selectedDeal {
            currentSavedDealId = deal.id
            let newDeal = SavedDeal()
            newDeal.name = deal.name
            newDeal.desc = deal.desc
            newDeal.tier = deal.tier
            newDeal.timeLimit = deal.timeLimit
            newDeal.expirationDate = deal.expirationDate
            newDeal.value = deal.value
            newDeal.restId = deal.restId
            newDeal.venueName = deal.venueName
            newDeal.image = deal.image
            newDeal.venueImageUrl = deal.venueImageUrl
            newDeal.hasImage = deal.hasImage
            //newDeal.venue = deal.venue
            newDeal.id = deal.id
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
            
            // create new local notification
            // temporaily set it for 1 minute from now
            let calendar = NSCalendar.autoupdatingCurrentCalendar()
            //var beforeExpireDate = calendar.dateByAddingUnit(.CalendarUnitMinute, value: -15, toDate: originalDate, options: nil)
            var now = NSDate()
            var soon = calendar.dateByAddingUnit(.CalendarUnitMinute, value: 1, toDate: now, options: nil)
            // self.selectedDeal!.expirationDate
            self.setCurrentDealLocalNotification(self.selectedDeal!.name, expireDate: soon!, dealId: self.selectedDeal!.dealId)
            println("Set up local notification")
            // if the user swapped, they already have credits updated
            if !didSwap {
                APICalls.shouldDecrementCreditForDeal(self.selectedDeal!.id as String, token: self.token, completion:{ result in
                    if result {
                        dispatch_async(dispatch_get_main_queue()){
                            println("Deal credits decremented")
                        }
                    } else {
                        dispatch_async(dispatch_get_main_queue()){
                            println("unable to decrement Deal credits")
                        }
                        
                    }
                })
            }
        }
    }
    
    func removeCurrentLocalNotification(dealId: String) {
        // see if we still have a notification for this deal scheduled, and delete if found
        for notification in UIApplication.sharedApplication().scheduledLocalNotifications as! [UILocalNotification] {
            if (notification.userInfo!["dealId"] as! String == dealId) {
                UIApplication.sharedApplication().cancelLocalNotification(notification)
                 println("Cancelled local notification")
                break
            }
        }
    }
    
    func setCurrentDealLocalNotification(dealName: String, expireDate: NSDate, dealId: String) {
        var notification = UILocalNotification()
        notification.alertBody = "The \"\(dealName)\" deal is about to expire!"
        notification.alertAction = "View"
        notification.fireDate = expireDate
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.userInfo = ["dealId": dealId, ]
        notification.category = "TODO_CATEGORY"
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
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
            selectedDeal = deal
            // set the timer to this deal
            setDealTimer(deal)
            if currentSavedDealId != "" {
                saveSwapButton.enabled = (currentSavedDealId == selectedDeal?.id) ? false : true
            }

            
        }  else if sender.tag == 2 {
            bestButton.selected = false
            oldestButton.selected = true
            //println(pageController.currentPage)
            pageController.currentPage = dealList.count - 1
            let indexPath = NSIndexPath(forRow: Int(dealList.count-1), inSection: 0)
            collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.Left, animated: true)
            let deal: VenueDeal = dealList[indexPath.row]
            // set the timer to this deal
            selectedDeal = deal
            setDealTimer(deal)
            if currentSavedDealId != "" {
                saveSwapButton.enabled = (currentSavedDealId == selectedDeal?.id) ? false : true
            }

        } else if sender.tag == 3 {
            // see if we have a saved deal
            println("user pressed saved deal button")
            var deal = realm.objects(SavedDeal).first
            if (deal != nil) {
                println("Saved deal")
                self.savedDeal = deal!
                collectionCardView.hidden = true
                cardButtonsView.hidden = true
                singleDealView.hidden = false
                saveSwapButton.enabled = false
                setUpSavedDeal()
                
            } else {
                println("No saved deals")
                let alertController = UIAlertController(title: "No Saved Deal", message: "Either your deal expired, or you haven't saved one yet.", preferredStyle: .Alert)
                // Add button action to swap
                let cancelMove = UIAlertAction(title: "Ok", style: .Default, handler: {
                    (action) -> Void in
                })
                alertController.addAction(cancelMove)
                presentViewController(alertController, animated: true, completion: nil)
            }
        
        }
    }

    
    func biddingStart(){
        if currentDealIndex < validDeals.count{
            // we have more deals to sort
            if lastDealRestId != "" {
                
                if lastDealRestId != validDeals[currentDealIndex].restId {
                    // Update lastDeal to hold the current restaurant id
                    lastDealRestId = validDeals[currentDealIndex].restId
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
                lastDealRestId = validDeals[currentDealIndex].restId
                dealList.insert(validDeals[currentDealIndex], atIndex: 0)
                currentDealIndex = currentDealIndex + 1
                delayLoad()
            }
            
        } else {
            
            // Once we are done with the array, hide the indicator, set the topDealReached, display the top
            // deal in the featured section
            topDealReached = true
            println("Top deal reached")
            self.actContainer.removeFromSuperview()
            self.actIndicator.stopAnimation()
            if dealList.count > 0 {
                selectedDeal = dealList[0]
                setDealTimer(selectedDeal!)
                if currentSavedDealId != "" {
                    saveSwapButton.enabled = (currentSavedDealId == selectedDeal?.id) ? false : true
                }
                searchBarButton.enabled = true
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
        //println("This deal's tier: \(deal.venuePriceTier)")
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
        timeLimitLabel.countDirection = 1
        timeLimitLabel.startValue = UInt64(seconds)
        timeLimitLabel.start()
        if seconds <= 0 {
            timeLimitLabel.stop()
            // set this deal to delete and the view to reload
        }
    }
    
    
    func setUpForInitialDeals(){
        self.navigationController?.view.addSubview(actContainer)
        actIndicator.startAnimation()
        dealList.removeAll()
        // delete any current venues
        var pulledVenues = Realm().objects(VenueDeal)
        if pulledVenues.count < 1 {
            realm.write {
                self.realm.delete(pulledVenues)
            }
        }
        
        // Start getting the users location
        manager = OneShotLocationManager()
        manager!.fetchWithCompletion {location, error in
            
            // fetch location or an error
            if let loc = location {
                self.location = loc
                if !self.haveLocation {
                    // we do now
                    self.haveLocation = true
                    self.userLocation = "lat=\(loc.coordinate.latitude)&lng=\(loc.coordinate.longitude)"
                    self.loadInitialDeals()
                }
            } else if let err = error {
                println("Unable to get user location: \(err.localizedDescription) error code: \(err.code)")
                self.actIndicator.stopAnimation()
                self.actContainer.removeFromSuperview()
            }
            // destroy the object immediately to save memory
            self.manager = nil
        }
    }
    
    func loadInitialDeals() {
        if searchBarButton != nil{
            searchBarButton.enabled = false
        }
        var token = prefs.stringForKey("TOKEN")
        //var userLocation = "lat=\(self.location.coordinate.latitude)&lng=\(self.location.coordinate.longitude)"
        var urlParameters: String = "venue/GetVenuesByPriceNLocation?priceTier=0&\(userLocation)"
    
        APICalls.getSaloofDeals(token!, venueParameters: urlParameters, completion: { result in
            if result {
                dispatch_async(dispatch_get_main_queue()){
                    self.refreshDataArray()
                    println("Refreshing data array from initial load")
                }
            } else {
                dispatch_async(dispatch_get_main_queue()){
                    self.actContainer.removeFromSuperview()
                    self.actIndicator.stopAnimation()
                    println("Unable to retrieve deals")
                }
            }
        })

    }
    // this method keeps looping
    
    func refreshDataArray(){
        haveItems = true
        //FINISHED CREATING DATA OBJECTS
        //get a list of all deal objects in Realm
        validDeals = Realm().objects(VenueDeal)
        println("We have \(validDeals.count) returned deals")
        if validDeals.count > 0 {
            //Sort all deals by value
            let sortedDeals = Realm().objects(VenueDeal).filter("\(Constants.dealValid) = \(1)").sorted("value", ascending:true)
            validDeals = sortedDeals
            self.actIndicator.stopAnimation()
            saveSwapButton.enabled = true
            cardButtonsView.hidden = false
            biddingStart()
        } else {
            self.actContainer.removeFromSuperview()
            self.actIndicator.stopAnimation()
            println("No results returned")
            var searchMessage = (searchQuery) ? "\(searchString)" : ""
            var priceMessage = (searchPrice) ? "\(searchString)" : ""
            if searchPrice {
                switch searchString {
                case "1":
                    priceMessage = "$"
                case "2":
                    priceMessage = "$$"
                case "3":
                    priceMessage = "$$$"
                case "4":
                        priceMessage = "$$$$"
                default:
                    priceMessage = ""
                }
            }
            alertUser("Bummer", message: "There are no \(priceMessage)\(searchMessage) deals near you")
            saveSwapButton.enabled = false
            timeLimitLabel.stop()
            timeLimitLabel.startValue = 0
            searchBarButton.enabled = true
            cardButtonsView.hidden = true
        }
    }
    
    //  ------------------  SEARCH TAGS AND PRICE PICKER METHODS ----------------------------
    

    // -------------------- PRICE POINT UIPICKERVIEW ----------------------------------
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
            searchPrice = false
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
             searchPrice = false
        }
        priceTextField.resignFirstResponder()
        // reload search
        didSelectPricePoint()
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = pickerDataSource[row]
        var myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 14.0)!,NSForegroundColorAttributeName:UIColor.blackColor()])
        return myTitle
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int,
        reusingView view: UIView!) -> UIView {
            var pickerLabel = view as! UILabel!
            if view == nil {  //if no label there yet
                pickerLabel = UILabel()
            }
            let titleData = pickerDataSource[row]
            let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 18.0)!,NSForegroundColorAttributeName:UIColor.blackColor()])
            pickerLabel!.attributedText = myTitle
            pickerLabel.textAlignment = .Center
            return pickerLabel
            
    }
    
    //size the components of the UIPickerView
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
        
    
    func didSelectPricePoint() {
        UIView.transitionWithView(self.searchDisplayOverview, duration: 0.5, options:
            .CurveEaseOut | .TransitionCrossDissolve, animations: {
                //...animations
            }, completion: {_ in
                self.resetView(true)
                
        })
    }
    
    
    func resetView(shouldSearch: Bool) {
        println("resetting view")
        //activityIndicator.startAnimation()
        searchDisplayOverview.hidden = true
        //searchPrice = shouldSearch
        self.navigationItem.setRightBarButtonItem(searchBarButton, animated: false)
        if shouldSearch {
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
         self.view.endEditing(true)
        self.navigationItem.setRightBarButtonItem(searchBarButton, animated: true)
        
    }
    
    
    
    func shouldCloseKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
        burgerTextField.text = ""
        burgerTextField.attributedPlaceholder = NSAttributedString(string:"Burger",
            attributes:[NSForegroundColorAttributeName: UIColor(red:0.93, green:0.93, blue:0.93, alpha:0.85)])
        burgerTextField.resignFirstResponder()
        priceTextField.resignFirstResponder()
    }
    
    
    func updateCurrentLocation (completion: Bool -> ()) {
        manager = OneShotLocationManager()
        manager!.fetchWithCompletion {location, error in
            
            // fetch location or an error
            if let loc = location {
                self.location = loc
                if !self.haveLocation {
                    // we do now
                    self.haveLocation = true
                    self.userLocation = "lat=\(loc.coordinate.latitude)&lng=\(loc.coordinate.longitude)"
                    self.manager = nil
                    completion(true)
                }
            } else if let err = error {
                println("Unable to get user location: \(err.localizedDescription) error code: \(err.code)")
                self.actContainer.removeFromSuperview()
                self.actIndicator.stopAnimation()
                self.manager = nil
                completion (false)
            }
        }
    }
    
    func fetchNewDeals() {
        var token = prefs.stringForKey("TOKEN")
        let searchTerm = (searchQuery) ? "category=\(searchString)" : ""
        let priceTier = (searchPrice) ? "priceTier=\(searchString)" : ""
        var userLocation = "lat=\(self.location.coordinate.latitude)&lng=\(self.location.coordinate.longitude)"
        var urlParameters: String = ""
        if searchQuery {
            urlParameters = "venue/GetVenuesByCategoryNLocation?\(searchTerm)&\(userLocation)"
        } else if searchPrice {
            urlParameters = "venue/GetVenuesByPriceNLocation?\(priceTier)&\(userLocation)"
        } else {
            urlParameters = "venue/GetVenuesByPriceNLocation?priceTier=0&\(userLocation)"
        }
        
        APICalls.getSaloofDeals(token!, venueParameters: urlParameters, completion: { result in
            if result{
                dispatch_async(dispatch_get_main_queue()){
                    println("refreshing data array from get local deals by price")
                    self.actIndicator.stopAnimation()
                    self.actContainer.removeFromSuperview()
                    self.refreshDataArray()
                }
            } else {
                dispatch_async(dispatch_get_main_queue()){
                    println("No new deals")
                    self.actIndicator.stopAnimation()
                    self.actContainer.removeFromSuperview()
                }
            }
        })
    }

    
    
    func pullNewSearchResults (pricePoint: Bool) {
        self.navigationController?.view.addSubview(actContainer)
        actIndicator.startAnimation()
        println("pulling new search")
        dealList.removeAll()
        collectionView.reloadData()
        // delete any current venues
        if searchBarButton != nil{
            searchBarButton.enabled = false
        }
        
        var pulledVenues = Realm().objects(VenueDeal)
        realm.write {
            self.realm.delete(pulledVenues)

        }
        haveLocation = false
        updateCurrentLocation() { result in
            if result {
                println("Have location, searching")
                // reset values
                self.lastDealRestId = ""
                self.topBidIndex = 0
                self.currentDealIndex = 0
                self.topDealReached = false
                self.pageController.currentPage = 0
                self.pageController.numberOfPages = 0
                
                var token = self.prefs.stringForKey("TOKEN")
                if self.searchQuery {
                    self.searchString = self.searchString.stringByReplacingOccurrencesOfString(" ", withString: "%20", options: NSStringCompareOptions.LiteralSearch, range: nil)
                }
                let searchTerm = (self.searchQuery) ? "category=\(self.searchString)" : ""
                let priceTier = (self.searchPrice) ? "priceTier=\(self.searchString)" : ""
                var userLocation = "lat=\(self.location.coordinate.latitude)&lng=\(self.location.coordinate.longitude)"
                var urlParameters: String = ""
                if self.searchQuery {
                    urlParameters = "venue/GetVenuesByCategoryNLocation?\(searchTerm)&\(userLocation)"
                } else if self.searchPrice {
                    urlParameters = "venue/GetVenuesByPriceNLocation?\(priceTier)&\(userLocation)"
                } else {
                    urlParameters = "venue/GetVenuesByPriceNLocation?priceTier=0&\(userLocation)"
                }
                
                APICalls.getSaloofDeals(token!, venueParameters: urlParameters, completion: { result in
                    if result{
                        dispatch_async(dispatch_get_main_queue()){
                            println("refreshing data array from get local deals by price")
                            self.actIndicator.stopAnimation()
                            self.actContainer.removeFromSuperview()
                            self.refreshDataArray()
                        }
                    } else {
                        dispatch_async(dispatch_get_main_queue()){
                            println("No new deals")
                            self.actIndicator.stopAnimation()
                            self.actContainer.removeFromSuperview()
                        }
                    }
                })
                self.searchDisplayOverview.hidden = true

            } else {
                println("Unable to get the users location")
                self.actIndicator.stopAnimation()
                self.actContainer.removeFromSuperview()
            }
        }
    }

    
    //  ---------------------  UITEXTFIELD DELEGATE  ---------------------------------
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.tag == 4 {
            println("User searching price")
            burgerTextField.text = ""
            burgerTextField.attributedPlaceholder = NSAttributedString(string:"Burger",
                attributes:[NSForegroundColorAttributeName: UIColor(red:0.93, green:0.93, blue:0.93, alpha:0.85)])
        } else if textField.tag == 3 {
            println("User searching tag")
            // user searching query
            textField.placeholder = ""
            priceTextField.attributedPlaceholder = NSAttributedString(string:"$",
                attributes:[NSForegroundColorAttributeName: UIColor(red:0.93, green:0.93, blue:0.93, alpha:0.85)])
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
                textField.attributedPlaceholder = NSAttributedString(string:"Burger",
                    attributes:[NSForegroundColorAttributeName: UIColor(red:0.93, green:0.93, blue:0.93, alpha:0.85)])
                pullNewSearchResults(false)
            }
        }
        return false
    }
    
    func alertUser(title: String, message: String) {
        var alertView:UIAlertView = UIAlertView()
        alertView.title = title
        alertView.message = message
        alertView.delegate = self
        alertView.addButtonWithTitle("OK")
        alertView.show()
    }
}
