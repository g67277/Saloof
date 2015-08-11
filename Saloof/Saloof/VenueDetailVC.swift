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
    @IBOutlet weak var addressTextview: UITextView!
    
    @IBOutlet weak var phoneTextView: UITextView!
    @IBOutlet weak var websiteUrlTextView: UITextView!
    @IBOutlet weak var hoursStatusLabel: UILabel!
    
    @IBOutlet weak var dealView: UIView!
    @IBOutlet weak var dealTitleLabel: UILabel!
    @IBOutlet weak var dealDescLabel: UILabel!
    @IBOutlet weak var dealValueLabel: UILabel!
    
    @IBOutlet var favoritesLabel: UILabel!
    @IBOutlet var likesLabel: UILabel!
    
    @IBOutlet var dealImage: UIImageView!
    
    var thisVenue: Venue?
    var favVenue: FavoriteVenue?
    var isFavorite: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage(named: "navBarLogo")
        navigationItem.titleView = UIImageView(image: image)
        
        // Do any additional setup after loading the view.
        if isFavorite {
            if let venue: FavoriteVenue = favVenue {
                setUpFavoriteVenue(venue)
            }
        } else {
            if let venue: Venue = thisVenue {
                setUpVenue(venue)
            }
        }
    }
    
    
    
    override func viewDidLayoutSubviews() {
        dealImage.layer.masksToBounds = false
        dealImage.layer.borderColor = UIColor.blackColor().CGColor
        dealImage.layer.cornerRadius = dealImage.frame.height/2
        dealImage.clipsToBounds = true
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
            // favoriteLikesView.hidden = true
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
            //imageView.contentMode = UIViewContentMode.ScaleAspectFill
            //imageView.clipsToBounds = true
            if venue.hasImage {
                imageView.image = venue.image
            } else {
                imageView.image = UIImage(named: "redHen")
            }
            if var dealImageView = dealImage {
                //dealImageView.contentMode = UIViewContentMode.ScaleAspectFill
                //dealImageView.clipsToBounds = true
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
    
    @IBAction func onClick(sender: UIButton) {
        if sender.tag == 1 {
            // user pressed favorite this restaurant
        } else if sender.tag == 2 {
            // user pressed like button
        }
    }
    
    /* -------------------------  SEGUE  -------------------------- */
    /*  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
    if segue.identifier == "shouldViewVenueDefaultDeal" {
    let detailVC = segue.destinationViewController as! RestaurantDealDetaislVC
    //create a temporary default deal
    var deal = createDealForDetailView()
    detailVC.thisDeal = deal
    detailVC.setUpForDefault = true
    detailVC.setUpForSaved = false
    }
    }*/
    
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

