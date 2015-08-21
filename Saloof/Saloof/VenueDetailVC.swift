//
//  VenueDetailVC.swift
//  Saloof
//
//  Created by Angela Smith on 7/15/15.
//  Copyright (c) 2015 SNASTek. All rights reserved.
//

import UIKit
import RealmSwift

class VenueDetailVC: UIViewController {
    
    @IBOutlet var halfStatsView: UIView!
    
    @IBOutlet var fsDistanceLabel: UILabel!
    @IBOutlet var fsPriceLabel: UILabel!
    
    @IBOutlet var fullStatsView: UIView!
    @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var priceTierlabel: UILabel!
    @IBOutlet weak var locationDistanceLabel: UILabel!
    @IBOutlet weak var locationName: UILabel!
    
    @IBOutlet weak var addressTextview: CustomTextView!
    @IBOutlet weak var phoneTextView: CustomTextView!
    @IBOutlet weak var websiteUrlTextView: CustomTextView!
    
    @IBOutlet weak var hoursStatusLabel: UILabel!
    
    @IBOutlet weak var dealView: UIView!
    @IBOutlet weak var dealTitleLabel: UILabel!
    @IBOutlet weak var dealDescLabel: UILabel!
    @IBOutlet weak var dealValueLabel: UILabel!
    
    @IBOutlet var favoritesLabel: UILabel!
    @IBOutlet var likesLabel: UILabel!
    
    @IBOutlet var clearLikeButton: UIButton!
    @IBOutlet var clearFavoriteButton: UIButton!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var favoriteButton: UIButton!
    @IBOutlet var dealImage: UIImageView!
    
    let realm = Realm()
    var thisVenue: Venue?
    var favVenue: FavoriteVenue?
    // Determines if came from favoritesVC
    var isFavorite: Bool = false
    // Determines if this user likes/favorites this venue
    var doesLike: Bool = false
    var doesFavorite: Bool = false
    var thisVenueId: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let image = UIImage(named: "navBarLogo")
        var homeButton =  UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        homeButton.frame = CGRectMake(0, 0, 100, 40) as CGRect
        homeButton.setImage(image, forState: UIControlState.Normal)
        homeButton.addTarget(self, action: Selector("returnHome"), forControlEvents: UIControlEvents.TouchUpInside)
        navigationItem.titleView = homeButton

        
        // Do any additional setup after loading the view.
        if isFavorite {
                if let venue: FavoriteVenue = favVenue {
                thisVenueId = venue.identifier
                    println("Id: \(thisVenueId)")
                setUpFavoriteVenue(venue)
            }
        } else {
            if let venue: Venue = thisVenue {
                thisVenueId = venue.identifier
                 println("Id: \(thisVenueId)")
                setUpVenue(venue)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        dealImage.layer.masksToBounds = false
        dealImage.layer.borderColor = UIColor.blackColor().CGColor
        dealImage.layer.cornerRadius = dealImage.frame.height/2
        dealImage.clipsToBounds = true
        
    }
    
    func returnHome() {
        println("User wants to return home")
        self.performSegueWithIdentifier("returnToUserHome", sender: self)
    }

    
    func setUpVenue(venue: Venue) {
        if var locationLabel = locationName {
            locationLabel.text = venue.name
        }
        if var phoneLabel = phoneTextView {
            phoneLabel.text = (venue.phone == "") ? "Unavailable" : venue.phone
        }
        if var addressTextView = addressTextview {
            addressTextView.text = (venue.address == "") ? "Unavailable" : venue.address
        }
        if var websiteTextView = websiteUrlTextView {
            websiteTextView.text = (venue.webUrl == "") ? "Unavailable" : venue.webUrl
        }
        if var statusLabel = hoursStatusLabel {
            let hours = venue.hours
            // set the status for the hours, or "Is Open" if one was not provided (only open locations are displayed)
            statusLabel.text = (venue.hours == "") ? "Is Open": venue.hours
        }
        
        if var imageView = locationImage {
            imageView.setImageCacheWithAddress(venue.imageUrl, placeHolderImage: UIImage (named: "placeholder")!)
        }
        
        
        // Default Deal
        if venue.sourceType == "Saloof" {
            setUpLikeNFavoriteButtons()
            // Set up the value
            let valueFloat:Float = venue.defaultDealValue, valueFormat = ".2"
            dealValueLabel.text = "Value: $\(valueFloat.format(valueFormat))"
            if var dealTitle = dealTitleLabel {
                dealTitle.text = venue.defaultDealTitle
            }
            if var dealDes = dealDescLabel {
                dealDes.text = venue.defaultDealDesc
            }
            if var favsLabel = favoritesLabel {
                favsLabel.text = "\(venue.favorites)"
            }
            if var likeLabel = likesLabel {
                likeLabel.text = "\(venue.likes)"
            }
            
            halfStatsView.hidden = true
            fullStatsView.hidden = false
            
            // Number Labels
            if var tierLabel = priceTierlabel {
                var priceTierValue = venue.priceTier
                switch priceTierValue {
                case 0:
                    tierLabel.text = ""
                case 1:
                    tierLabel.text = "$"
                case 2:
                    tierLabel.text = "$$"
                case 3:
                    tierLabel.text = "$$$"
                default:
                    tierLabel.text = ""
                }
            }
            
            if var distanceLabel = locationDistanceLabel {
                // get the number of miles between the current user and the location,
                var distance = venue.distance
                distanceLabel.text  = distance
            }
            
            if var dealImageView = dealImage {
                dealImageView.setImageCacheWithAddress(venue.imageUrl, placeHolderImage: UIImage (named: "placeholder")!)
            }
            
            clearFavoriteButton.enabled = true
            clearLikeButton.enabled = true
            favoriteButton.hidden = false
            likeButton.hidden = false

        } else {
            // hide the deal and favorites views
            dealView.hidden = true
            halfStatsView.hidden = false
            fullStatsView.hidden = true
            clearFavoriteButton.enabled = false
            clearLikeButton.enabled = false
            favoriteButton.hidden = true
            likeButton.hidden = true
            // Number Labels
            if var tierLabel = fsPriceLabel {
                var priceTierValue = venue.priceTier
                switch priceTierValue {
                case 0:
                    tierLabel.text = ""
                case 1:
                    tierLabel.text = "$"
                case 2:
                    tierLabel.text = "$$"
                case 3:
                    tierLabel.text = "$$$"
                default:
                    tierLabel.text = ""
                }
            }
            
            if var distanceLabel = fsDistanceLabel {
                // get the number of miles between the current user and the location,
                var distance = venue.distance
                distanceLabel.text  = distance
            }
        }
        
    }
    
    func setUpFavoriteVenue(venue:FavoriteVenue) {
        if var locationLabel = locationName {
            locationLabel.text = venue.name
        }
        if var phoneLabel = phoneTextView {
            phoneLabel.text = (venue.phone == "") ? "Unavailable" : venue.phone
        }
        if var addressTextView = addressTextview {
            addressTextView.text = (venue.address == "") ? "Unavailable" : venue.address
        }
        if var websiteTextView = websiteUrlTextView {
            websiteTextView.text = (venue.webUrl == "") ? "Unavailable" : venue.webUrl
        }
        if var statusLabel = hoursStatusLabel {
            let hours = venue.hours
            // set the status for the hours, or "Is Open" if one was not provided (only open locations are displayed)
            statusLabel.text = (venue.hours == "") ? "Is Open": venue.hours
        }
        
        if var imageView = locationImage {
            imageView.setImageCacheWithAddress(venue.imageUrl, placeHolderImage: UIImage (named: "placeholder")!)
        }
        
        // Default Deal
        if venue.sourceType == "Saloof" {
            // Set up the value
            let valueFloat:Float = venue.defaultDealValue, valueFormat = ".2"
            dealValueLabel.text = "Value: $\(valueFloat.format(valueFormat))"
            if var dealTitle = dealTitleLabel {
                dealTitle.text = venue.defaultDealTitle
            }
            if var dealDes = dealDescLabel {
                dealDes.text = venue.defaultDealDesc
            }
            if var favsLabel = favoritesLabel {
                favsLabel.text = "\(venue.favorites)"
            }
            if var likeLabel = likesLabel {
                likeLabel.text = "\(venue.likes)"
            }
            
            halfStatsView.hidden = true
            fullStatsView.hidden = false
            
            // Number Labels
            if var tierLabel = priceTierlabel {
                var priceTierValue = venue.priceTier
                switch priceTierValue {
                case 0:
                    tierLabel.text = ""
                case 1:
                    tierLabel.text = "$"
                case 2:
                    tierLabel.text = "$$"
                case 3:
                    tierLabel.text = "$$$"
                default:
                    tierLabel.text = ""
                }
            }
            
            if var distanceLabel = locationDistanceLabel {
                // get the number of miles between the current user and the location,
                var distance = venue.distance
                distanceLabel.text  = distance
            }
            
            if var dealImageView = dealImage {
                dealImageView.setImageCacheWithAddress(venue.imageUrl, placeHolderImage: UIImage (named: "placeholder")!)
            }
            setUpLikeNFavoriteButtons()
            
        } else {
            // hide the deal and favorites views
            dealView.hidden = true
            halfStatsView.hidden = false
            fullStatsView.hidden = true
            // Number Labels
            if var tierLabel = fsPriceLabel {
                var priceTierValue = venue.priceTier
                switch priceTierValue {
                case 0:
                    tierLabel.text = ""
                case 1:
                    tierLabel.text = "$"
                case 2:
                    tierLabel.text = "$$"
                case 3:
                    tierLabel.text = "$$$"
                default:
                    tierLabel.text = ""
                }
            }
            
            if var distanceLabel = fsDistanceLabel {
                // get the number of miles between the current user and the location,
                var distance = venue.distance
                distanceLabel.text  = distance
            }
        }
        
    }
    
    func setImageWithURL(imgAddress: String) {
        locationImage?.setImageCacheWithAddress(imgAddress, placeHolderImage: UIImage (named: "placeholder")!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // -------------------- LIKING / UNLIKING  / FAVORITING  / UNFAVORITING  ----------------------
    func setUpLikeNFavoriteButtons() {        
        var favoriteVenue = realm.objectForPrimaryKey(FavoriteVenue.self, key: thisVenueId)
        // see if we have a favorite venue with this id
            if favoriteVenue != nil {
            // set the favorite button on
                favoriteButton.selected = true
                doesFavorite = true
            } else {
                // did the user come from the favorites list
                if isFavorite {
                    favoriteButton.selected = true
                    doesFavorite = true
                } else {
                    // not a favorite
                    favoriteButton.selected = false
                    doesFavorite = false
                }
        }
        // see if this id is stored as a liked venue
        var likedVenue = realm.objectForPrimaryKey(LikedVenue.self, key: thisVenueId)
        if likedVenue != nil {
            // set the liked button on
            doesLike = true
            likeButton.selected = true
        } else {
            doesLike = false
            likeButton.selected = false
        }
        
    }
    
    
    @IBAction func onClick(sender: UIButton) {
        println("This venue id: \(thisVenueId)")
        // like == 2, favorite == 3
        if sender.tag == 2 {
            if doesLike {
                println("Unliking")
                self.doesLike = false
                self.likeButton.selected = false
                self.shouldUpdateLikeCountForVenue(false)
                // unlike/unselect this venue
                var likedVenue = realm.objectForPrimaryKey(LikedVenue.self, key: thisVenueId)
                if likedVenue != nil {
                    realm.write {
                        self.realm.delete(likedVenue!)
                    }
                }
                // remove like from API
                APICalls.updateLikeCountForVenue(thisVenueId, didLike: false, completion: { result in
                    if result {
                        dispatch_async(dispatch_get_main_queue()){
                            println("User unliked this venue")
                        }
                    }
                })

            } else {
                println("Liking")
                likeButton.selected = true
                doesLike = true
                self.shouldUpdateLikeCountForVenue(true)
                // like and select
                var newVenueLike = LikedVenue()
                newVenueLike.likedId = thisVenueId
                realm.write {
                    realm.create(LikedVenue.self, value: newVenueLike, update: true)
                }
                // add like to API
                APICalls.updateLikeCountForVenue(thisVenueId, didLike: true, completion: { result in
                    if result {
                        dispatch_async(dispatch_get_main_queue()){
                            println("User liked this venue")
                        }
                    }
                })
            }
        } else if sender.tag == 3 {
            // remove this venue
            if doesFavorite {
                println("unfavoriting")
                self.favoriteButton.selected = false
                self.doesFavorite = false
                self.shouldUpdateFavoriteCountForVenue(false)
                // unlike/unselect this venue
                var favVenue = realm.objectForPrimaryKey(FavoriteVenue.self, key: thisVenueId)
                if favVenue != nil {
                    realm.write {
                        //self.realm.delete(favVenue!)
                        favVenue?.swipeValue = 2
                        self.realm.create(FavoriteVenue.self, value: favVenue!, update: true)
                    }
                }
                
                // remove favorite from API
                APICalls.updateFavoriteCountForVenue(thisVenueId, didFav: false, completion: { result in
                    if result {
                        dispatch_async(dispatch_get_main_queue()){
                            println("User unfavorited this venue")
                        }
                    }
                })
            } else {
                println("favoriting")
                self.shouldUpdateFavoriteCountForVenue(true)
                // fav and select
                doesFavorite = true
                favoriteButton.selected = true
                // make sure there is a favorite venue saved
                var favoriteVenue = realm.objectForPrimaryKey(FavoriteVenue.self, key: thisVenueId)
                if favoriteVenue == nil {
                    if isFavorite {
                        println("Resaving venue as favorite")
                        // create the whole object
                        var favorite = FavoriteVenue()
                        // create from the current favorite object
                        favorite.name = favVenue!.name
                        favorite.phone = favVenue!.phone
                        favorite.webUrl = favVenue!.webUrl
                        favorite.image = favVenue!.image
                        favorite.imageUrl = favVenue!.imageUrl
                        favorite.distance = favVenue!.distance
                        favorite.identifier = favVenue!.identifier
                        favorite.address = favVenue!.address
                        favorite.priceTier = favVenue!.priceTier
                        favorite.hours = favVenue!.hours
                        favorite.swipeValue = 1
                        favorite.hasImage = favVenue!.hasImage
                        favorite.sourceType = favVenue!.sourceType
                        // save deal
                        if favVenue!.sourceType == Constants.sourceTypeSaloof {
                            favorite.defaultDealTitle = favVenue!.defaultDealTitle
                            favorite.defaultDealID = favVenue!.defaultDealID
                            favorite.defaultDealValue = favVenue!.defaultDealValue
                            favorite.defaultDealDesc = favVenue!.defaultDealDesc
                        }
                        favorite.favorites =  favVenue!.favorites
                        favorite.likes =  favVenue!.likes
                        realm.write {
                            self.realm.create(FavoriteVenue.self, value: favorite, update: true)
                        }
                        
                    } else {
                        println("Saving new venue from tinder ui as favorite")
                        var favorite = FavoriteVenue()
                        // create from the current favorite object
                        favorite.name = thisVenue!.name
                        favorite.phone = thisVenue!.phone
                        favorite.webUrl = thisVenue!.webUrl
                        favorite.image = thisVenue!.image
                        favorite.distance = thisVenue!.distance
                        favorite.identifier = thisVenue!.identifier
                        favorite.address = thisVenue!.address
                        favorite.imageUrl = thisVenue!.imageUrl
                        favorite.priceTier = thisVenue!.priceTier
                        favorite.hours = thisVenue!.hours
                        favorite.swipeValue = 1
                        favorite.hasImage = thisVenue!.hasImage
                        favorite.sourceType = thisVenue!.sourceType
                        // save deal
                        if thisVenue!.sourceType == Constants.sourceTypeSaloof {
                            favorite.defaultDealTitle = thisVenue!.defaultDealTitle
                            favorite.defaultDealID = thisVenue!.defaultDealID
                            favorite.defaultDealValue = thisVenue!.defaultDealValue
                            favorite.defaultDealDesc = thisVenue!.defaultDealDesc
                        }
                        favorite.favorites =  thisVenue!.favorites
                        favorite.likes =  thisVenue!.likes
                        realm.write {
                            self.realm.create(FavoriteVenue.self, value: favorite, update: true)
                        }
                    }
                }
                APICalls.updateFavoriteCountForVenue(thisVenueId, didFav: true, completion: { result in
                    if result {
                        println("user favorited this venue")
                    }
                })
                
            }
        }
    }
    
    
    func shouldUpdateLikeCountForVenue(shouldIncrease: Bool) {
        var updatedCount: Int = 0
        var currentCount: Int = 0
        // Get the object type
        if isFavorite {
            // this is a FavoriteVenue object
            if let venue: FavoriteVenue = favVenue {
                currentCount = venue.likes
                if shouldIncrease {
                    updatedCount = currentCount + 1
                } else {
                    // they are unliking
                    if currentCount > 0 {
                        // decrement it by one
                        updatedCount = currentCount - 1
                    }
                }
                // Update the object and label
                realm.write {
                    self.favVenue?.likes = updatedCount
                    self.realm.create(FavoriteVenue.self, value: self.favVenue!, update: true)
                }
            }
        } else {
            // This is a Venue object
            if let venue: Venue = thisVenue {
                currentCount = venue.likes
                if shouldIncrease {
                    updatedCount = currentCount + 1
                } else {
                    // they are unliking
                    if currentCount > 0 {
                        // decrement it by one
                        updatedCount = currentCount - 1
                    }
                }
                // Update the object and label
                realm.write {
                    self.thisVenue?.likes = updatedCount
                    self.realm.create(Venue.self, value: self.thisVenue!, update: true)
                }
            }
        }
        // update the label
        if var likeLabel = likesLabel {
            likeLabel.text = "\(updatedCount)"
        }
    }
    
    func shouldUpdateFavoriteCountForVenue(shouldIncrease: Bool) {
        var updatedCount: Int = 0
        var currentCount: Int = 0
        // Get the object type
        if isFavorite {
            // this is a FavoriteVenue object
            if let venue: FavoriteVenue = favVenue {
                currentCount = venue.favorites
                if shouldIncrease {
                    updatedCount = currentCount + 1
                } else {
                    // they are unliking
                    if currentCount > 0 {
                        // decrement it by one
                        updatedCount = currentCount - 1
                    }
                }
                // Update the object and label
                realm.write {
                    self.favVenue?.favorites = updatedCount
                    self.realm.create(FavoriteVenue.self, value: self.favVenue!, update: true)
                }
            }
        } else {
            // This is a Venue object
            if let venue: Venue = thisVenue {
                currentCount = venue.favorites
                if shouldIncrease {
                    updatedCount = currentCount + 1
                } else {
                    // they are unliking
                    if currentCount > 0 {
                        // decrement it by one
                        updatedCount = currentCount - 1
                    }
                }
                // Update the object and label
                realm.write {
                    self.thisVenue?.favorites = updatedCount
                    self.realm.create(Venue.self, value: self.thisVenue!, update: true)
                }
            }
        }
        // update the label
        if var favLab = favoritesLabel {
            favLab.text = "\(updatedCount)"
        }
    }
    
    
    func createDealForDetailView()-> VenueDeal {
        let venueDeal = VenueDeal()
        venueDeal.name = dealTitleLabel.text!
        venueDeal.desc = dealDescLabel.text!
        venueDeal.tier = 0
        venueDeal.timeLimit = 4
        if isFavorite {
            venueDeal.value = favVenue!.defaultDealValue
            venueDeal.venueName = favVenue!.name
            venueDeal.id = favVenue!.defaultDealID
            venueDeal.image = favVenue!.image
            venueDeal.hasImage = favVenue!.hasImage
            venueDeal.restId = favVenue!.identifier

        } else  {
            venueDeal.value = thisVenue!.defaultDealValue
            venueDeal.venueName = thisVenue!.name
            venueDeal.id = thisVenue!.defaultDealID
            venueDeal.restId = thisVenue!.identifier
            venueDeal.hasImage = thisVenue!.hasImage
            venueDeal.image = thisVenue!.image
        }
        let realm = Realm()
        realm.write {
            realm.create(VenueDeal.self, value: venueDeal, update: true)
        }
        
        return venueDeal
    }
    
    @IBAction func shouldPushToSavedDeal(sender: AnyObject) {
        // Check to make sure we have a saved deal
        let realm = Realm()
        var savedDeal = realm.objects(SavedDeal).first
        if (savedDeal != nil) {
            if (savedDeal != nil) {
                let valid = checkDealIsValid(savedDeal!)
                if valid {
                    let storyboard = UIStoryboard(name: "User", bundle: NSBundle.mainBundle())
                    let dealsVC: VenueDealsVC = storyboard.instantiateViewControllerWithIdentifier("userDealsVC") as! VenueDealsVC
                    dealsVC.loadSingleDeal = true
                    dealsVC.setUpForSaved = true
                    dealsVC.savedDeal = savedDeal!
                    navigationController?.pushViewController(dealsVC, animated: true)
                }
            } else {
                alertUser("No Deal", message: "Either your deal expired, or you haven't saved one.")
            }
        } else {
            alertUser("No Deal", message: "Either your deal expired, or you haven't saved one.")
        }
    }
    
    func checkDealIsValid (savedDeal: SavedDeal) -> Bool {
        // we need to check the date
        var realm = Realm()
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
                realm.delete(savedDeal)
            }
            return false
        }
    }
    
    @IBAction func shouldLoadDefaultDealInDealView(sender: AnyObject) {
        // Check to make sure we have a saved deal
        let storyboard = UIStoryboard(name: "User", bundle: NSBundle.mainBundle())
        let dealsVC: VenueDealsVC = storyboard.instantiateViewControllerWithIdentifier("userDealsVC") as! VenueDealsVC
        dealsVC.loadSingleDeal = true
        dealsVC.setUpForDefault = true
        dealsVC.setUpForSaved = false
        let defaultDeal = VenueDeal()
        defaultDeal.name = thisVenue!.defaultDealTitle
        defaultDeal.hasImage = thisVenue!.hasImage
        defaultDeal.image = thisVenue!.image
        defaultDeal.restId = thisVenue!.identifier
        defaultDeal.desc = thisVenue!.defaultDealDesc
        //defaultDeal.venue = thisVenue!
        defaultDeal.value = thisVenue!.defaultDealValue
        defaultDeal.id = thisVenue!.defaultDealID
        dealsVC.singleDeal = defaultDeal
        navigationController?.pushViewController(dealsVC, animated: true)
        
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
