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
        navigationItem.titleView = UIImageView(image: image)
        
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
        setUpLikeNFavoriteButtons()
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
        
        // Images
        if venue.hasImage {
            if var imageView = locationImage {
                imageView.image = venue.image
                imageView.contentMode = UIViewContentMode.ScaleAspectFill
                imageView.clipsToBounds = true
            }
            if var dealImageView = dealImage {
                dealImageView.image = venue.image
                dealImageView.contentMode = UIViewContentMode.ScaleAspectFill
                dealImageView.clipsToBounds = true
            }
        } else {
            if var imageView = locationImage {
                imageView.image = UIImage(named: "redHen")
                imageView.contentMode = UIViewContentMode.ScaleAspectFill
                imageView.clipsToBounds = true
            }
            if var dealImageView = dealImage {
                dealImageView.image = UIImage(named: "redHen")
                dealImageView.contentMode = UIViewContentMode.ScaleAspectFill
                dealImageView.clipsToBounds = true
            }
            
        }
        
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
            var userDistance = venue.distance
            var miles = userDistance/5280
            let distance = Int(floor(miles))
            distanceLabel.text = (distance == 1) ? "\(distance) mile" : "\(distance) miles"
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
            // set up the deal
        } else {
            // hide the deal and favorites views
            dealView.hidden = true
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
        
        // Images
        if var imageView = locationImage {
            if venue.hasImage {
                imageView.image = venue.image
            } else {
                imageView.image = UIImage(named: "redHen")
            }
            if var dealImageView = dealImage {
                if venue.hasImage {
                    dealImageView.image = venue.image
                } else {
                    dealImageView.image = UIImage(named: "redHen")
                }
            }
        }
        
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
            var userDistance = venue.distance
            var miles = userDistance/5280
            let distance = Int(floor(miles))
            distanceLabel.text = (distance == 1) ? "\(distance) mile" : "\(distance) miles"
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
            // set up the deal
        } else {
            // hide the deal and favorites views
            dealView.hidden = true
            // favoriteLikesView.hidden = true
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // -------------------- LIKING / UNLIKING  / FAVORITING  / UNFAVORITING  ----------------------
    func setUpLikeNFavoriteButtons() {
        // And favorites button
        // Check if this venue is included in the liked or favorites lists
        var likedVenue = realm.objectForPrimaryKey(LikedVenue.self, key: thisVenueId)
        if likedVenue != nil {
            // set the liked button on
            doesLike = true
            likeButton.selected = true
        } else {
            doesLike = false
            likeButton.selected = true
        }
        var favoriteVenue = realm.objectForPrimaryKey(FavoriteVenue.self, key: thisVenueId)
        if favoriteVenue != nil {
            // set the favorite button on
            favoriteButton.selected = true
            doesFavorite = true
        } else {
            favoriteButton.selected = false
            doesFavorite = false
        }
        
    }
    
    
    @IBAction func onClick(sender: UIButton) {
        println("This venue id: \(thisVenueId)")
        // like == 2, favorite == 3
        if sender.tag == 2 {
            if doesLike {
                println("Unliking")
                // unlike/unselect this venue
                var likedVenue = realm.objectForPrimaryKey(LikedVenue.self, key: thisVenueId)
                if likedVenue != nil {
                    realm.write {
                        self.realm.delete(likedVenue!)
                    }
                }
                doesLike = false
                likeButton.selected = false
            } else {
                println("Liking")
                // like and select
                var newVenueLike = LikedVenue()
                newVenueLike.likedId = thisVenueId
                realm.write {
                    realm.create(LikedVenue.self, value: newVenueLike, update: true)
                }
                likeButton.selected = true
                doesLike = true
            }
        } else if sender.tag == 3 {
            // remove this venue
            if doesFavorite {
                println("unfavoriting")
                // unlike/unselect this venue
                var favVenue = realm.objectForPrimaryKey(FavoriteVenue.self, key: thisVenueId)
                if favVenue != nil {
                    realm.write {
                        self.realm.delete(favVenue!)
                    }
                }
                favoriteButton.selected = false
                doesFavorite = false
            } else {
                println("favoriting")
                // fav and select
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
                        var favorite = Venue()
                        // create from the current favorite object
                        favorite.name = thisVenue!.name
                        favorite.phone = thisVenue!.phone
                        favorite.webUrl = thisVenue!.webUrl
                        favorite.image = thisVenue!.image
                        favorite.distance = thisVenue!.distance
                        favorite.identifier = thisVenue!.identifier
                        favorite.address = thisVenue!.address
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
                favoriteButton.selected = true
                isFavorite = true
            }
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
            venueDeal.venue.name = favVenue!.name
            venueDeal.venue.identifier = favVenue!.identifier
            venueDeal.venue.image = favVenue!.image
            var venueId = "\(venueDeal.venue.identifier).0)"
            venueDeal.id = venueId
        } else  {
            venueDeal.value = thisVenue!.defaultDealValue
            venueDeal.venue.name = thisVenue!.name
            venueDeal.venue.identifier = thisVenue!.identifier
            var venueId = "\(venueDeal.venue.identifier).0)"
            venueDeal.venue.image = thisVenue!.image
            venueDeal.id = venueId
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
    
    @IBAction func shouldLoadDefaultDealInDealView(sender: AnyObject) {
        // Check to make sure we have a saved deal
        let storyboard = UIStoryboard(name: "User", bundle: NSBundle.mainBundle())
        let dealsVC: VenueDealsVC = storyboard.instantiateViewControllerWithIdentifier("userDealsVC") as! VenueDealsVC
        dealsVC.loadSingleDeal = true
        dealsVC.setUpForDefault = true
        dealsVC.setUpForSaved = false
        let defaultDeal = VenueDeal()
        defaultDeal.name = thisVenue!.defaultDealTitle
        defaultDeal.venue = thisVenue!
        defaultDeal.value = thisVenue!.defaultDealValue
        defaultDeal.id = thisVenue!.defaultDealID
        dealsVC.singleDeal = defaultDeal
        navigationController?.pushViewController(dealsVC, animated: true)
        
    }
}
