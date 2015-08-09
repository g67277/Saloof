//
//  UserHomeVC.swift
//  Saloof
//
//  Created by Angela Smith on 8/8/15.
//  Copyright (c) 2015 SNASTek. All rights reserved.
//

import UIKit
import RealmSwift
import Koloda
import CoreLocation
import SwiftyJSON

class UserHomeVC:  UIViewController, KolodaViewDataSource, KolodaViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate,  UIPickerViewDataSource, UIPickerViewDelegate {
    
    typealias JSONParameters = [String: AnyObject]
    
    // Realm Data properties
    let realm = Realm()
    var venues = Realm().objects(Venue)
    var haveItems: Bool = false
    let venueList = List<Venue>()
    
    // Location Properties
    var locationManager : CLLocationManager!
    var venueLocations : [AnyObject] = []
    var venueItems : [[String: AnyObject]]?
    var currentLocation: CLLocation!
    
    //View Properties
    @IBOutlet var dealButton: UIBarButtonItem!
    @IBOutlet weak var searchDisplayOverview: UIView!
    @IBOutlet weak var swipeableView: KolodaView!
    @IBOutlet var activityView: UIView!
    @IBOutlet var indicatorView: UIView!
    @IBOutlet var activityLabel: UILabel!
    var searchBarButton: UIBarButtonItem!
    var cancelButton: UIBarButtonItem!
    let activityIndicator = CustomActivityView(frame: CGRect (x: 0, y: 0, width: 70, height: 70), color: UIColor.orangeColor(), size: CGSize(width: 70, height: 70))
    
    @IBOutlet var menuView: UIView!
    
    // Search
    @IBOutlet var burgerTextField: UITextField!
    @IBOutlet var searchView: UIView!
    @IBOutlet var priceView: UIView!
    @IBOutlet var priceTextField: UITextField!
    @IBOutlet var searchPickerView: UIView!
    @IBOutlet var pickerSpinnerView: UIView!
    @IBOutlet var searchPicker: UIPickerView!
    
    // Search Properties
    var searchActive : Bool = false
    var searchPrice : Bool = false
    var searchString = ""
    var offsetCount: Int = 0
    var pickerDataSource = ["Any","$", "$$", "$$$", "$$$$"];
    
    let prefs: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    
    /* -----------------------  VIEW CONTROLLER METHODS --------------------------- */
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up the Kolodo view delegate and data source
        swipeableView.dataSource = self
        swipeableView.delegate = self
        indicatorView.addSubview(activityIndicator)
        let image = UIImage(named: "navBarLogo")
        navigationItem.titleView = UIImageView(image: image)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func onClick(sender: UIButton) {
        if sender.tag == 3 {
            //log out
            menuView.hidden = true
            prefs.setObject(nil, forKey: "TOKEN")
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }
    }
    
    func displayMenu (){
        menuView.hidden = !menuView.hidden
        shouldCloseSearch()
    }
    
    override func viewDidAppear(animated: Bool) {
        // Add the second button to the nav bar
        let menuButton = UIBarButtonItem(image: UIImage(named: "menuButton"), style: .Plain, target: self, action: "displayMenu")
        searchBarButton = UIBarButtonItem(image: UIImage(named: "searchButton"), style: .Plain, target: self, action: "shouldOpenSearch")
        cancelButton = UIBarButtonItem(image: UIImage(named: "closeIcon"), style: .Plain, target: self, action: "shouldCloseSearch")
        self.navigationItem.setRightBarButtonItem(searchBarButton, animated: false)
        self.navigationItem.setLeftBarButtonItems([menuButton, self.dealButton], animated: true)
        
        burgerTextField.attributedPlaceholder = NSAttributedString(string:"Burger",
            attributes:[NSForegroundColorAttributeName: UIColor(red:0.93, green:0.93, blue:0.93, alpha:0.85)])
        
        priceTextField.attributedPlaceholder = NSAttributedString(string:"$",
            attributes:[NSForegroundColorAttributeName: UIColor(red:0.93, green:0.93, blue:0.93, alpha:0.85)])
        searchView.roundCorners(.AllCorners, radius: 14)
        priceView.roundCorners(.AllCorners, radius: 14)
        if venueList.count == 0 {
            getLocationPermissionAndData()
        }
    }
    
    
    func activityIndicatorDisplaying(appear: Bool, message: String) {
        if appear {
            activityView.hidden = false
            activityIndicator.startAnimation()
            activityLabel.text = message
        } else {
            activityView.hidden = true
            activityIndicator.stopAnimation()
        }
    }
    
    func getLocationPermissionAndData() {
        // delete any items in the array
        venueList.removeAll()
        // delete any current venues
        var rejectedVenues = Realm().objects(Venue).filter("\(Constants.realmFilterFavorites) = \(2)")
        var unswipedVenues = Realm().objects(Venue).filter("\(Constants.realmFilterFavorites) = \(0)")
        realm.write {
            self.realm.delete(rejectedVenues)
            self.realm.delete(unswipedVenues)
        }
        // Start getting the users location
        //activityIndicatorDisplaying(true, message: "Locating...")
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.delegate = self
        // check device location permission status
        let status = CLLocationManager.authorizationStatus()
        if status == .NotDetermined {
            // Request access
            locationManager.requestWhenInUseAuthorization()
            activityIndicatorDisplaying(false, message: "")
        } else if status == CLAuthorizationStatus.AuthorizedWhenInUse
            || status == CLAuthorizationStatus.AuthorizedAlways {
                // we have permission, get location
                locationManager.startUpdatingLocation()
        } else {
            // We do not have premission, request it
            requestLocationPermission()
            //activityIndicatorDisplaying(false, message: "")
        }
        
    }
    
    /* --------  SEARCH BAR DISPLAY AND DELEGATE METHODS ---------- */
    
    // -------------------- UIPICKERVIEW ----------------------------------
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
        searchActive = true
        searchPrice = true
        switch row {
        case 0:
            priceTextField.text = "";
            searchString = ""
            // reload search
            didSelectPricePoint(false)
        case 1:
            priceTextField.text = "$";
            searchString = "1"
            didSelectPricePoint(true)
        case 2:
            priceTextField.text = "$$";
            searchString = "2"
            didSelectPricePoint(true)
        case 3:
            priceTextField.text = "$$$";
            searchString = "3"
            didSelectPricePoint(true)
        case 4:
            priceTextField.text = "$$$$";
            searchString = "4"
            didSelectPricePoint(true)
        default:
            priceTextField.text = ""
            searchString = ""
            didSelectPricePoint(false)
        }
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
    
    func didSelectPricePoint(shouldSearch: Bool) {
        UIView.transitionWithView(searchPickerView, duration: 0.5, options:
            .CurveEaseOut | .TransitionCrossDissolve, animations: {
                //...animations
            }, completion: {_ in
                self.searchPickerView.hidden = true
                UIView.transitionWithView(self.searchDisplayOverview, duration: 0.5, options:
                    .CurveEaseOut | .TransitionCrossDissolve, animations: {
                        //...animations
                    }, completion: {_ in
                        self.resetView(shouldSearch)
                        
                })
        })
    }
    
    func resetView(shouldSearch: Bool) {
        searchDisplayOverview.hidden = true
        searchActive = shouldSearch
        searchPrice = shouldSearch
        self.navigationItem.setRightBarButtonItem(searchBarButton, animated: false)
        if shouldSearch {
            // reload search
            pullNewSearchResults()
        }
    }
    
    
    func shouldOpenSearch () {
        searchDisplayOverview.hidden = false
        menuView.hidden = true
        self.navigationItem.setRightBarButtonItem(cancelButton, animated: true)
        
    }
    
    func shouldCloseSearch () {
        searchDisplayOverview.hidden = true
        searchActive = false;
        burgerTextField.text = ""
        burgerTextField.editing
        self.navigationItem.setRightBarButtonItem(searchBarButton, animated: true)
        
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
        self.view.endEditing(true)
        self.navigationItem.setRightBarButtonItem(searchBarButton, animated: true)
        // see which text field was entered
        if textField.tag == 3 {
            // Search
            if textField.text != "" {
                searchString = textField.text
                searchActive = true
                textField.text = ""
                pullNewSearchResults()
            }
        }
        return false
    }
    
    func pullNewSearchResults () {
        venueList.removeAll()
        // delete any current venues
        var rejectedVenues = Realm().objects(Venue).filter("\(Constants.realmFilterFavorites) = \(2)")
        var unswipedVenues = Realm().objects(Venue).filter("\(Constants.realmFilterFavorites) = \(0)")
        realm.write {
            self.realm.delete(rejectedVenues)
            self.realm.delete(unswipedVenues)
        }
        // reset the offset
        offsetCount = 0
        swipeableView.resetCurrentCardNumber()
        // get more foursquare items
        fetchFoursquareVenues()
        searchDisplayOverview.hidden = true
        swipeableView.reloadData()
    }
    
    
    /* --------  SWIPEABLE KOLODA VIEW ACTIONS, DATA SOURCE, AND DELEGATE METHODS ---------- */
    
    @IBAction func leftButtonTapped() {
        swipeableView?.swipe(SwipeResultDirection.Left)
    }
    
    @IBAction func rightButtonTapped() {
        swipeableView?.swipe(SwipeResultDirection.Right)
    }
    
    // KolodaView DataSource
    func kolodaNumberOfCards(koloda: KolodaView) -> UInt {
        
        return UInt(venueList.count)
    }
    
    func kolodaViewForCardAtIndex(koloda: KolodaView, index: UInt) -> UIView {
        //Check this for a better fix of the sizing issue...
        //println("bounds for first 3: \(self.swipeableView.bounds)")
        
        var cardView = CardContentView(frame: self.swipeableView.bounds)
        var contentView = NSBundle.mainBundle().loadNibNamed("CardContentView", owner: self, options: nil).first! as! UIView
        contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        let restaurant: Venue = venueList[Int(index)]
        //println(restaurant)
        cardView.setUpRestaurant(contentView, dataObject: restaurant)
        cardView.addSubview(contentView)
        // Layout constraints to keep card view within the swipeable view bounds as it moves
        let metrics = ["width":cardView.bounds.width, "height": cardView.bounds.height]
        let views = ["contentView": contentView, "cardView": cardView]
        cardView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[contentView(width)]", options: .AlignAllLeft, metrics: metrics, views: views))
        cardView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[contentView(height)]", options: .AlignAllLeft, metrics: metrics, views: views))
        
        cardView.roundCorners( .AllCorners, radius: 14)
        return cardView
    }
    
    func kolodaViewForCardOverlayAtIndex(koloda: KolodaView, index: UInt) -> OverlayView? {
        return NSBundle.mainBundle().loadNibNamed("CardOverlayView",
            owner: self, options: nil)[0] as? OverlayView
    }
    
    //KolodaView Delegate
    
    func kolodaDidSwipedCardAtIndex(koloda: KolodaView, index: UInt, direction: SwipeResultDirection) {
        let swipedVenue: Venue = venueList[Int(index)]
        println(swipedVenue)
        // check the direction
        if direction == SwipeResultDirection.Left {
            // set up for deletion
            realm.write {
                swipedVenue.swipeValue = 2
                self.realm.create(Venue.self, value: swipedVenue, update: true)
            }
        }
        if direction == SwipeResultDirection.Right {
            // save this venue as a favorite
            var favorite = FavoriteVenue()
            favorite.name = swipedVenue.name
            favorite.phone = swipedVenue.phone
            favorite.webUrl = swipedVenue.webUrl
            favorite.image = swipedVenue.image
            favorite.distance = swipedVenue.distance
            favorite.identifier = swipedVenue.identifier
            favorite.address = swipedVenue.address
            favorite.priceTier = swipedVenue.priceTier
            favorite.hours = swipedVenue.hours
            favorite.swipeValue = 1
            favorite.hasImage = swipedVenue.hasImage
            favorite.sourceType = swipedVenue.sourceType
            // save deal
            if swipedVenue.sourceType == Constants.sourceTypeSaloof {
                favorite.defaultDealTitle = swipedVenue.defaultDealTitle
                favorite.defaultDealID = swipedVenue.defaultDealID
                favorite.defaultDealValue = swipedVenue.defaultDealValue
                favorite.defaultDealDesc = swipedVenue.defaultDealDesc
            }
            favorite.favorites =  swipedVenue.favorites
            favorite.likes =  swipedVenue.likes
            realm.write {
                self.realm.create(FavoriteVenue.self, value: favorite, update: true)
                // and set up this one for deletion
                swipedVenue.swipeValue = 2
                self.realm.create(Venue.self, value: swipedVenue, update: true)
            }
        }
        
    }
    
    func removeRejectedVenues () {
        println("removing rejected venues")
        // remove each from the list
        for venue in venueList {
            if venue.swipeValue == 2 {
                venueList.delete(venue)
            }
        }
        // get all the rejected venues from realm
        var rejectedVenues = Realm().objects(Venue).filter("\(Constants.realmFilterFavorites) = \(2)")
        realm.write {
            self.realm.delete(rejectedVenues)
        }
        // update the venues array (test to see if this handles the out of bounds issue)
        venues = Realm().objects(Venue)
    }
    
    func kolodaDidRunOutOfCards(koloda: KolodaView) {
        println("Ran out of cards, getting foursquare locations")
        activityIndicatorDisplaying(true, message: "Saloofing...")
        removeRejectedVenues()
        swipeableView.resetCurrentCardNumber()
        // get more foursquare items
        fetchFoursquareVenues()
    }
    
    func kolodaDidSelectCardAtIndex(koloda: KolodaView, index: UInt) {
        // get the venue at the index and pass to the detail view
        let venue: Venue = venues[Int(index)]
        let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("restaurantDetailVC") as! VenueDetailVC
        self.navigationController?.pushViewController(detailVC, animated: true)
        detailVC.thisVenue = venue
        detailVC.isFavorite = false
    }
    
    
    func kolodaShouldApplyAppearAnimation(koloda: KolodaView) -> Bool {
        return true
    }
    
    
    // ------------------- USER LOCATION PERMISSION REQUEST  ----------------------
    
    func requestLocationPermission() {
        let alertController = UIAlertController(title: "Need Location", message: "To find great restaurants, we need access to your location", preferredStyle: .Alert)
        // Add button action to directly open the settings
        let openSettings = UIAlertAction(title: "Open settings", style: .Default, handler: {
            (action) -> Void in
            let URL = NSURL(string: UIApplicationOpenSettingsURLString)
            UIApplication.sharedApplication().openURL(URL!)
            //self.dismissViewControllerAnimated(true, completion: nil)
        })
        alertController.addAction(openSettings)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showErrorAlert(error: NSError) {
        let alertController = UIAlertController(title: "Our Bad!", message:"Sorry, but we are having trouble finding where you are right now. Maybe try agian later.", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Ok", style: .Default, handler: {
            (action) -> Void in
        })
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .Denied || status == .Restricted {
            requestLocationPermission()
        } else {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        showErrorAlert(error)
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        // once we have locations, stop retrieving their location
        locationManager.stopUpdatingLocation()
        // if we dont' have any locations, get some
        if venueList.count == 0 {
            //println("No restaurants stored")
            //exploreFoursquareVenues()
            //loadSaloofData()
        } else {
            // println("restaurants stored")
        }
        fetchSaloofVenues()
    }
    
    
    func fetchSaloofVenues() {
        var token = prefs.stringForKey("TOKEN")
        let location = self.locationManager.location
        var userLocation = "?lat=\(location.coordinate.latitude)&lng=\(location.coordinate.longitude)"
        if APICalls.getLocalVenues(token!, location: userLocation){
            println("Pulling data from saloof!!")
            for venue in venues {
                venueList.append(venue)
            }
            fetchFoursquareVenues()
            swipeableView.reloadData()
        } else {
            println("Not Pulling data from saloof!!")
            // pull from foursquare
            fetchFoursquareVenues()
            swipeableView.reloadData()
        }
        
    }
    
    /*
    func fetchSaloofVenues () {
    let saloofUrl = NSURL(string: "http://www.justwalkingonwater.com/json/venueResponse.json")!
    let response = NSData(contentsOfURL: saloofUrl)!
    println(response)
    let json: AnyObject? = (NSJSONSerialization.JSONObjectWithData(response,
    options: NSJSONReadingOptions(0),
    error: nil) as! NSDictionary)["response"]
    
    if let object: AnyObject = json {
    haveItems = true
    var groups = object["groups"] as! [AnyObject]
    //  get array of items
    var venues = groups[0]["items"] as! [AnyObject]
    for item in venues {
    // get the venue
    if let venue = item["venue"] as? JSONParameters {
    println(venue)
    let venueJson = JSON(venue)
    // Parse the JSON file using SwiftlyJSON
    parseJSON(venueJson, source: Constants.sourceTypeSaloof)
    }
    }
    }
    // see if we have at least 10 venues
    if venues.count < 10 {
    println("We have room for more venues, adding foursquare locations")
    // load some foursquare locations
    fetchFoursquareVenues()
    } else {
    println("We have enough saloof vanues, loading locations")
    swipeableView.reloadData()
    activityIndicatorDisplaying(false, message: "")
    }
    
    }
    */
    func fetchFoursquareVenues() {
        // Begin loading data from foursquare
        // get the location & possible search string
        let searchTerm = (searchActive) ? "&query=\(searchString)" : "&section=food"
        let priceTier = (searchPrice) ? "&price=\(searchString)" : ""
        let location = self.locationManager.location
        let userLocation  = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
        let foursquareURl = NSURL(string: "https://api.foursquare.com/v2/venues/explore?&client_id=KNSDVZA1UWUPSYC1QDCHHTLD3UG5HDMBR5JA31L3PHGFYSA0&client_secret=U40WCCSESYMKAI4UYAWGK2FMVE3CBMS0FTON0KODNPEY0LBR&openNow=1&v=20150101&m=foursquare&venuePhotos=1&limit=10&offset=\(offsetCount)&ll=\(userLocation)\(searchTerm)\(priceTier)")!
        println(foursquareURl)
        if  let response = NSData(contentsOfURL: foursquareURl) {
            let json: AnyObject? = (NSJSONSerialization.JSONObjectWithData(response,
                options: NSJSONReadingOptions(0),
                error: nil) as! NSDictionary)["response"]
            
            if let object: AnyObject = json {
                haveItems = true
                var groups = object["groups"] as! [AnyObject]
                //  get array of items
                var venues = groups[0]["items"] as! [AnyObject]
                for item in venues {
                    // get the venue
                    if let venue = item["venue"] as? JSONParameters {
                        //println(venue)
                        let venueJson = JSON(venue)
                        // Parse the JSON file using SwiftlyJSON
                        parseJSON(venueJson, source: Constants.sourceTypeFoursquare)
                    }
                }
                println("Data gathering completed, retrieved \(venues.count) venues")
                // swipeableView.reloadData()
                activityIndicatorDisplaying(false, message: "")
            }
            offsetCount = offsetCount + 10
        } else {
            activityIndicatorDisplaying(false, message: "That's It!")
        }
        // De-serialize the response to JSON
    }
    
    
    func parseJSON(json: JSON, source: String) {
        let venue = Venue()
        venue.identifier = json["id"].stringValue
        venue.phone = json["contact"]["formattedPhone"].stringValue /* Not working*/
        venue.name = json["name"].stringValue
        venue.webUrl = json["url"].stringValue                       /* Not working*/
        let imagePrefix = json["photos"]["groups"][0]["items"][0]["prefix"].stringValue
        let imageSuffix = json["photos"]["groups"][0]["items"][0]["suffix"].stringValue
        let imageName = imagePrefix + "400x400" +  imageSuffix
        var locationAddress = json["location"]["formattedAddress"][0].stringValue
        var cityAddress = json["location"]["formattedAddress"][1].stringValue
        venue.address = locationAddress + "\n" + cityAddress
        venue.hours = json["hours"]["status"].stringValue
        venue.distance = json["location"]["distance"].floatValue
        venue.priceTier = json["price"]["tier"].intValue
        venue.sourceType = source
        if source == Constants.sourceTypeSaloof {
            // get the default deal
            venue.defaultDealTitle = json["deals"]["deal"][0]["title"].stringValue
            venue.defaultDealDesc = json["deals"]["deal"][0]["description"].stringValue
            venue.defaultDealValue = json["deals"]["deal"][0]["value"].floatValue
            venue.favorites = json[Constants.restStats][Constants.restFavorites].intValue
            venue.likes = json[Constants.restStats][Constants.restLikes].intValue
        }
        let imageUrl = NSURL(string: imageName)
        if let data = NSData(contentsOfURL: imageUrl!){
            
            let venueImage = UIImage(data: data)
            venue.image = venueImage
            venue.hasImage = true
        }
        
        realm.write {
            //self.realm.add(venue)
            self.realm.create(Venue.self, value: venue, update: true)
        }
        venueList.append(venue)
    }
    
    @IBAction func shouldPushToSavedDeal(sender: AnyObject) {
        // Check to make sure we have a saved deal
        var savedDeal = realm.objects(SavedDeal).first
        if (savedDeal != nil) {
            let storyboard = UIStoryboard(name: "User", bundle: NSBundle.mainBundle())
            let dealsVC: VenueDealsVC = storyboard.instantiateViewControllerWithIdentifier("userDealsVC") as! VenueDealsVC
            dealsVC.loadSingleDeal = true
            dealsVC.setUpForSaved = true
            dealsVC.savedDeal = savedDeal!
            navigationController?.pushViewController(dealsVC, animated: true)
        } else {
            // Alert them there isn't a current valid saved deal
            let alertController = UIAlertController(title: "No Deals", message: "Either your deal expired, or you haven't saved one.", preferredStyle: .Alert)
            // Add button action to swap
            let cancelMove = UIAlertAction(title: "Ok", style: .Default, handler: {
                (action) -> Void in
            })
            alertController.addAction(cancelMove)
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    // Pass the selected restaurant deal object to the detail view
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "mainToFavoritesSegue" {
            // rehide the menu
            menuView.hidden = true
        }
    }
}
