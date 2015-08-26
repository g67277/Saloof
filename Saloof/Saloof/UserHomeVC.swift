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


class UserHomeVC:  UIViewController, KolodaViewDataSource, KolodaViewDelegate, UITextFieldDelegate,  UIPickerViewDataSource, UIPickerViewDelegate {
    
    typealias JSONParameters = [String: AnyObject]
    
    // Realm Data properties
    let realm = Realm()
    var venues = Realm().objects(Venue)
    var haveItems: Bool = false
    let venueList = List<Venue>()
    
    // Location Properties
    var location: CLLocation!
    var venueLocations : [AnyObject] = []
    var venueItems : [[String: AnyObject]]?
    var manager: OneShotLocationManager?
    var imageCache = [String:UIImage] ()

    
    //View Properties
    @IBOutlet var menuButton: UIBarButtonItem!
    @IBOutlet weak var swipeableView: KolodaView!
    @IBOutlet var indicatorView: UIView!
    var searchBarButton: UIBarButtonItem!
    var dealsButton: UIBarButtonItem!
    var cancelButton: UIBarButtonItem!
    let activityIndicator = CustomActivityView(frame: CGRect (x: 0, y: 0, width: 100, height: 100), color: UIColor(red:0.98, green:0.39, blue:0.2, alpha:1), size: CGSize(width: 100, height: 100))
    var containerView = CreateActivityView.createView(UIColor.clearColor(), frame: UIScreen.mainScreen().bounds)
    
    @IBOutlet var menuView: UIView!
    
    // Search
    @IBOutlet weak var searchDisplayOverview: UIView!
    @IBOutlet var burgerTextField: UITextField!
    @IBOutlet var searchView: UIView!
    @IBOutlet var priceView: UIView!
    @IBOutlet var priceTextField: UITextField!
    
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
        var pickerView = UIPickerView()
        pickerView.delegate = self
        priceTextField.inputView = pickerView
        
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
        
        // set up for the actifity indicator
        activityIndicator.center = self.containerView.center
        self.containerView.addSubview(activityIndicator)
        self.containerView.center = self.view.center
        
        // GET LOCATION
        getLocationPermissionAndData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        searchView.roundCorners(.AllCorners, radius: 14)
        priceView.roundCorners(.AllCorners, radius: 14)
    }
    
    
    @IBAction func displayMenu(sender: AnyObject) {
        menuView.hidden = !menuView.hidden
        shouldCloseSearch()
        
    }
    
    
    @IBAction func onClick(sender: UIButton) {
        if sender.tag == 3 {
            menuView.hidden = true
            let storyboard = UIStoryboard(name: "User", bundle: NSBundle.mainBundle())
            let profileVC: UserProfileVC = storyboard.instantiateViewControllerWithIdentifier("userProfile") as! UserProfileVC
            profileVC.navigationItem.title = nil
            navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    
    @IBAction func openPricePicker(sender: AnyObject) {
       priceTextField.tintColor = UIColor.clearColor()
        if priceTextField.isFirstResponder() {
             //println("is responder")
            priceTextField.resignFirstResponder()
        } else {
          //  println("becomming responder")
            priceTextField.becomeFirstResponder()
        }
    }
  
    func getLocationPermissionAndData() {
        self.navigationController?.view.addSubview(containerView)
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
        
        manager = OneShotLocationManager()
        manager!.fetchWithCompletion {location, error in
            
            // fetch location or an error
            if let loc = location {
               self.location = loc
                self.checkLocationAndAccess()
            } else if let err = error {
                 println("Unable to get user location: \(err.localizedDescription) error code: \(err.code)")
                self.containerView.removeFromSuperview()
                self.activityIndicator.stopAnimation()
                self.showErrorAlert()
            }
            // destroy the object immediately to save memory
            self.manager = nil
        }
    }
    
    func showErrorAlert() {
        let alertController = UIAlertController(title: nil, message:"Sorry, but we are having trouble finding where you are right now. Please check your location settings.", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Ok", style: .Default, handler: {
            (action) -> Void in
        })
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
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
        //activityIndicator.startAnimation()
        self.navigationController?.view.addSubview(containerView)
        activityIndicator.startAnimation()
        searchDisplayOverview.hidden = true
        //searchPrice = shouldSearch
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
        burgerTextField.endEditing(true)
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
    
    //  ---------------------  UITEXTFIELD DELEGATE  ---------------------------------
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.tag == 4 {
            burgerTextField.text = ""
            burgerTextField.attributedPlaceholder = NSAttributedString(string:"Burger",
                attributes:[NSForegroundColorAttributeName: UIColor(red:0.93, green:0.93, blue:0.93, alpha:0.85)])
        } else if textField.tag == 3 {
            // user searching query
            textField.placeholder = ""
            priceTextField.attributedPlaceholder = NSAttributedString(string:"$",
                attributes:[NSForegroundColorAttributeName: UIColor(red:0.93, green:0.93, blue:0.93, alpha:0.85)])
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
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
                textField.attributedPlaceholder = NSAttributedString(string:"Burger",
                    attributes:[NSForegroundColorAttributeName: UIColor(red:0.93, green:0.93, blue:0.93, alpha:0.85)])
                pullNewSearchResults()
            }
        }
        return false
    }
    
    func pullNewSearchResults () {
        self.navigationController?.view.addSubview(containerView)
        activityIndicator.startAnimation()
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
        
        
        var cardView = NSBundle.mainBundle().loadNibNamed("CardView",
            owner: self, options: nil)[0] as? CardView
        let restaurant: Venue = venueList[Int(index)]
        cardView?.setImageWithURL(restaurant.imageUrl)
        cardView?.venueImageView?.contentMode = UIViewContentMode.ScaleAspectFill
        cardView?.venueImageView?.clipsToBounds = true
        cardView?.venueNameLabel?.text = restaurant.name
        cardView?.venuePhoneLabel?.text = restaurant.phone
        cardView?.setBorderShadow()
        return cardView!

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
            favorite.imageUrl = swipedVenue.imageUrl
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
            if favorite.sourceType == Constants.sourceTypeSaloof {
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
        
    }

    
    func kolodaDidRunOutOfCards(koloda: KolodaView) {
        self.navigationController?.view.addSubview(containerView)
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
    

    func checkLocationAndAccess () {
        if Reachability.isConnectedToNetwork(){
            // check their location from D.C.
            var dcLocation = CLLocation(latitude: 38.9, longitude: -77.0)
            var distanceBetween: CLLocationDistance = location.distanceFromLocation(dcLocation!)
            var distanceInMiles = distanceBetween / 1609.344
            if distanceInMiles > 40 {
                self.containerView.removeFromSuperview()
                self.activityIndicator.stopAnimation()
                alertUser("No Saloof Locations", message: "Looks like you are outside our deals area, but we can still show you some great locations near you!")
                // just look for foursquare locations
                fetchFoursquareVenues()
                swipeableView.reloadData()
            } else {
                // begin loading saloof & foursquare locations
                self.navigationItem.setLeftBarButtonItems([self.menuButton, self.dealsButton], animated: true)
                fetchSaloofVenues()
            }
        } else {
            self.containerView.removeFromSuperview()
            self.activityIndicator.stopAnimation()
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
                    self.swipeableView.reloadData()
                }
            } else {
                dispatch_async(dispatch_get_main_queue()){
                    self.fetchFoursquareVenues()
                    self.swipeableView.reloadData()
                }
            }
        })
    }

    
    func fetchFoursquareVenues() {
        // Begin loading data from foursquare
        // get the location & possible search
        
        let searchTerm = (searchQuery) ? "&query=restaurants,\(searchString)" : "&query=restaurants"
        let priceTier = (searchPrice) ? "&price=\(searchString)" : ""
        //let location = self.locationManager.location
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
                println("Foursquare returned \(venues.count) venues")
            }
            offsetCount = offsetCount + 10
        }
        self.containerView.removeFromSuperview()
        self.activityIndicator.stopAnimation()
    }
    
    
    func parseJSON(json: JSON, source: String) {
        let venue = Venue()
        venue.identifier = json["id"].stringValue
        venue.phone = json["contact"]["formattedPhone"].stringValue
        venue.name = json["name"].stringValue
        venue.webUrl = json["url"].stringValue
        let imagePrefix = json["photos"]["groups"][0]["items"][0]["prefix"].stringValue
        let imageSuffix = json["photos"]["groups"][0]["items"][0]["suffix"].stringValue
        let imageName = imagePrefix + "400x400" +  imageSuffix
        // Address
        venue.imageUrl = imagePrefix + "400x400" +  imageSuffix
        var locationStreet = json["location"]["address"].stringValue
        var locationCity = json["location"]["city"].stringValue
        var locationState = json["location"]["state"].stringValue
        var locationZip = json["location"]["postalCode"].stringValue
        var address = locationStreet + "\n" + locationCity + ", " + locationState + "  " + locationZip
        venue.address = address
        venue.hours = json["hours"]["status"].stringValue
        var distanceInMeters = json["location"]["distance"].floatValue
        var distanceInMiles = distanceInMeters / 1609.344
        // make sure it is greater than 0
        distanceInMiles = (distanceInMiles > 0) ? distanceInMiles : 0
        var formattedDistance : String = String(format: "%.01f", distanceInMiles)
        venue.distance = formattedDistance
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
            let valid = checkDealIsValid(savedDeal!)
            if valid {
                let storyboard = UIStoryboard(name: "User", bundle: NSBundle.mainBundle())
                let dealsVC: VenueDealsVC = storyboard.instantiateViewControllerWithIdentifier("userDealsVC") as! VenueDealsVC
                dealsVC.loadSingleDeal = true
                dealsVC.setUpForSaved = true
                dealsVC.savedDeal = savedDeal!
                dealsVC.navigationItem.title = nil
                navigationController?.pushViewController(dealsVC, animated: true)
            } else {
                alertUser("No Deal", message: "Either your deal expired, or you haven't saved one.")
            }
        } else {
            alertUser("No Deal", message: "Either your deal expired, or you haven't saved one.")
        }
    }
    
    // Pass the selected restaurant deal object to the detail view
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "mainToFavoritesSegue" {
            // rehide the menu
            menuView.hidden = true
        }
    }
    
    @IBAction func returnToUserHomeSegue(segue:UIStoryboardSegue) {
        
    }
    
    func alertUser(title: String, message: String) {
        var alertView:UIAlertView = UIAlertView()
        alertView.title = title
        alertView.message = message
        alertView.delegate = self
        alertView.addButtonWithTitle("OK")
        alertView.show()
    }
    
    func checkDealIsValid (savedDeal: SavedDeal) -> Bool {
        // we need to check the date
        var realm = Realm()
        let expiresTime = savedDeal.expirationDate
        // see how much time has lapsed
        var compareDates: NSComparisonResult = NSDate().compare(expiresTime)
        if compareDates == NSComparisonResult.OrderedAscending {
            // the deal has not expired yet
            return true
        } else {
            //the deal has expired
            realm.write {
                realm.delete(savedDeal)
            }
            return false
        }
    }

}