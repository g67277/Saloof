//
//  UserHomeVC.swift
//  Saloof
//
//  Created by Angela Smith on 8/8/15.
//  Copyright (c) 2015 SNASTek. All rights reserved.
// DC Lat: 38.9047  Lng -77.0164

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
    
    //View Properties
    @IBOutlet var menuButton: UIBarButtonItem!
    @IBOutlet weak var swipeableView: KolodaView!
    @IBOutlet var indicatorView: UIView!
    var searchBarButton: UIBarButtonItem!
    var dealsButton: UIBarButtonItem!
    var cancelButton: UIBarButtonItem!
    let activityIndicator = CustomActivityView(frame: CGRect (x: 0, y: 0, width: 100, height: 100), color: UIColor(red:0.98, green:0.39, blue:0.2, alpha:1), size: CGSize(width: 100, height: 100))
    
    @IBOutlet var menuView: UIView!
    
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
        
        
        // close search when user taps outside search field
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "shouldCloseKeyboard")
        searchDisplayOverview.addGestureRecognizer(tap)
        
        
        // Add the second button to the nav bar
        dealsButton = UIBarButtonItem(image: UIImage(named: "dealIcon"), style: .Plain, target: self, action: "loadDeals")
        searchBarButton = UIBarButtonItem(image: UIImage(named: "searchButton"), style: .Plain, target: self, action: "shouldOpenSearch")
        cancelButton = UIBarButtonItem(image: UIImage(named: "closeIcon"), style: .Plain, target: self, action: "shouldCloseSearch")
        self.navigationItem.setRightBarButtonItem(searchBarButton, animated: false)
        // self.navigationItem.setLeftBarButtonItems([menuButton, self.dealButton], animated: true)
        
        burgerTextField.attributedPlaceholder = NSAttributedString(string:"Burger",
            attributes:[NSForegroundColorAttributeName: UIColor(red:0.93, green:0.93, blue:0.93, alpha:0.85)])
        
        priceTextField.attributedPlaceholder = NSAttributedString(string:"$",
            attributes:[NSForegroundColorAttributeName: UIColor(red:0.93, green:0.93, blue:0.93, alpha:0.85)])
        searchView.roundCorners(.AllCorners, radius: 14)
        priceView.roundCorners(.AllCorners, radius: 14)
        // GET LOCATION
        getLocationPermissionAndData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func displayMenu(sender: AnyObject) {
        menuView.hidden = !menuView.hidden
        shouldCloseSearch()
        
    }
    @IBAction func onClick(sender: UIButton) {
        if sender.tag == 3 {
            //LOG OUT USER
            menuView.hidden = true
            prefs.setObject(nil, forKey: "TOKEN")
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }
    }

    
    override func viewDidAppear(animated: Bool) {
    }
    
  
    func getLocationPermissionAndData() {
        activityIndicator.startAnimation()
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
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.delegate = self
        // check device location permission status
        let status = CLLocationManager.authorizationStatus()
        if status == .NotDetermined {
            // Request access
            activityIndicator.stopAnimation()
            locationManager.requestWhenInUseAuthorization()
        } else if status == CLAuthorizationStatus.AuthorizedWhenInUse
            || status == CLAuthorizationStatus.AuthorizedAlways {
                // we have permission, get location
                locationManager.startUpdatingLocation()
        } else {
            // We do not have premission, request it
            activityIndicator.stopAnimation()
            requestLocationPermission()
        }
        
    }
    
    /* --------  SEARCH BAR DISPLAY AND DELEGATE METHODS ---------- */
    
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
        UIView.transitionWithView(searchPickerView, duration: 0.5, options:
            .CurveEaseOut | .TransitionCrossDissolve, animations: {
                //...animations
            }, completion: {_ in
                self.searchPickerView.hidden = true
                UIView.transitionWithView(self.searchDisplayOverview, duration: 0.5, options:
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
        searchQuery = false;
        searchPrice = false
        burgerTextField.text = ""
        burgerTextField.editing
        self.navigationItem.setRightBarButtonItem(searchBarButton, animated: true)
        
    }
    
    func shouldCloseKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
        searchPickerView.hidden = true
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
        self.view.endEditing(true)
        self.navigationItem.setRightBarButtonItem(searchBarButton, animated: true)
        // see which text field was entered
        if textField.tag == 3 {
            // Search
            if textField.text != "" {
                searchString = textField.text
                searchString = searchString.stringByReplacingOccurrencesOfString(" ", withString: "%20", options: NSStringCompareOptions.LiteralSearch, range: nil)
                searchQuery = true
                searchPrice = false
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
        fetchSaloofVenues()
        activityIndicator.stopAnimation()
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
        // stop the imageview from filling out the whole view
        
        contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        let restaurant: Venue = venueList[Int(index)]
        //println(restaurant.identifier)
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
            APICalls.updateFavoriteCountForVenue(favorite.identifier, didFav: true, completion: { result in
                if result {
                    dispatch_async(dispatch_get_main_queue()){
                            println("Favorited this venue")
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()){
                        println("unable to favorite this venue")
                    }

                }
            })
        }
        
    }

    
    func kolodaDidRunOutOfCards(koloda: KolodaView) {
        println("Ran out of cards, getting foursquare locations")
        activityIndicator.startAnimation()
        resetSwipeableVieForReload()
    }
    
    func resetSwipeableVieForReload() {
    
        venueList.removeAll()
        // delete any current venues
        var rejectedVenues = Realm().objects(Venue).filter("\(Constants.realmFilterFavorites) = \(2)")
        var unswipedVenues = Realm().objects(Venue).filter("\(Constants.realmFilterFavorites) = \(0)")
        realm.write {
            self.realm.delete(rejectedVenues)
            self.realm.delete(unswipedVenues)
        }
        swipeableView.resetCurrentCardNumber()
        fetchFoursquareVenues()
        activityIndicator.stopAnimation()
        swipeableView.reloadData()
        
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
        })
        alertController.addAction(openSettings)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showErrorAlert(error: NSError) {
        activityIndicator.stopAnimation()
        let alertController = UIAlertController(title: "Our Bad!", message:"Sorry, but we are having trouble finding where you are right now. Maybe try again later.", preferredStyle: .Alert)
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
        checkLocationAndAccess()
    }
    
    
    func checkLocationAndAccess () {
        activityIndicator.stopAnimation()
        if Reachability.isConnectedToNetwork(){
            
            // check their location from D.C.
            let currentLocation = self.locationManager.location
            var dcLocation = CLLocation(latitude: 38.9, longitude: -77.0)
            var distanceBetween: CLLocationDistance = currentLocation.distanceFromLocation(dcLocation!)
            var distanceInMiles = distanceBetween / 1609.344
            if distanceInMiles > 40 {
                alertUser("No Saloof Locations", message: "Looks like you are outside our deals area, but we can still show you some great locations near you!")
                // just look for foursquare locations
                fetchFoursquareVenues()
                swipeableView.reloadData()
            } else {
                // begin loading saloof & foursquare locations
                self.navigationItem.setLeftBarButtonItems([self.menuButton, self.dealsButton], animated: true)
                activityIndicator.startAnimation()
                fetchSaloofVenues()
            }
        } else {
            self.alertUser("No Network", message: "Please make sure you are connected then try again")
        }

    
    }
    
    func loadDeals() {
        let storyboard = UIStoryboard(name: "User", bundle: NSBundle.mainBundle())
        let dealsVC: VenueDealsVC = storyboard.instantiateViewControllerWithIdentifier("userDealsVC") as! VenueDealsVC
        dealsVC.navigationItem.title = nil
        navigationController?.pushViewController(dealsVC, animated: true)

    
    }
    func fetchSaloofVenues() {
        activityIndicator.startAnimation()
        var token = prefs.stringForKey("TOKEN")
        let searchTerm = (searchQuery) ? "category=\(searchString)" : ""
        let priceTier = (searchPrice) ? "priceTier=\(searchString)" : ""
        let location = self.locationManager.location
        var userLocation = "lat=\(location.coordinate.latitude)&lng=\(location.coordinate.longitude)"
        var urlParameters: String = ""
        if searchQuery {
            urlParameters = "venue/GetVenuesByCategoryNLocation?\(searchTerm)&\(userLocation)"
        } else if searchPrice {
            urlParameters = "venue/GetVenuesByPriceTierNLocation?\(priceTier)&\(userLocation)"
        } else {
            urlParameters = "Venue/GetLocal?\(userLocation)"
        }
        //println(urlParameters)
        /*
        if APICalls.getLocalVenues(token!, venueParameters: urlParameters){
            //println("Pulling data from saloof!!")
            for venue in venues {
                venueList.append(venue)
            }
            //makesure the deals button is viewable
            self.navigationItem.setLeftBarButtonItems([self.menuButton, self.dealsButton], animated: true)
        } else {
            //println("No Locations saloof locations near this user")
        }
        fetchFoursquareVenues()
        activityIndicator.stopAnimation()
        swipeableView.reloadData()*/
        
        APICalls.getLocalVenues(token!, venueParameters: urlParameters, completion: { result in
            if result {
                dispatch_async(dispatch_get_main_queue()){
                    //println("Pulling local data asyncly from saloof!!")
                    for venue in self.venues {
                        self.venueList.append(venue)
                    }
                    //makesure the deals button is viewable
                    self.navigationItem.setLeftBarButtonItems([self.menuButton, self.dealsButton], animated: true)
                    self.fetchFoursquareVenues()
                    self.activityIndicator.stopAnimation()
                    self.swipeableView.reloadData()
                }
            } else {
                dispatch_async(dispatch_get_main_queue()){
                    self.fetchFoursquareVenues()
                    self.activityIndicator.stopAnimation()
                    self.swipeableView.reloadData()
                }
            }
            
        })
    }

    
    func fetchFoursquareVenues() {
        // Begin loading data from foursquare
        // get the location & possible search
        let searchTerm = (searchQuery) ? "&query=\(searchString)" : "&query=restaurants"
        let priceTier = (searchPrice) ? "&price=\(searchString)" : ""
        let location = self.locationManager.location
        let userLocation  = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
        let foursquareURl = NSURL(string: "https://api.foursquare.com/v2/venues/explore?&client_id=KNSDVZA1UWUPSYC1QDCHHTLD3UG5HDMBR5JA31L3PHGFYSA0&client_secret=U40WCCSESYMKAI4UYAWGK2FMVE3CBMS0FTON0KODNPEY0LBR&openNow=1&v=20150101&m=foursquare&venuePhotos=1&limit=10&offset=\(offsetCount)&ll=\(userLocation)\(searchTerm)\(priceTier)")!
        //println(foursquareURl)
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
            }
            offsetCount = offsetCount + 10
        }
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
        // Address
        var locationStreet = json["location"]["address"].stringValue
        var locationCity = json["location"]["city"].stringValue
        var locationState = json["location"]["state"].stringValue
        var locationZip = json["location"]["postalCode"].stringValue
        var address = locationStreet + "\n" + locationCity + ", " + locationState + "  " + locationZip
        venue.address = address
        venue.hours = json["hours"]["status"].stringValue
        venue.distance = json["location"]["distance"].floatValue
        venue.priceTier = json["price"]["tier"].intValue
        venue.sourceType = source
        venue.swipeValue = 0
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
            dealsVC.navigationItem.title = nil
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
    
    func alertUser(title: String, message: String) {
        var alertView:UIAlertView = UIAlertView()
        alertView.title = title
        alertView.message = message
        alertView.delegate = self
        alertView.addButtonWithTitle("OK")
        alertView.show()
    }
}
