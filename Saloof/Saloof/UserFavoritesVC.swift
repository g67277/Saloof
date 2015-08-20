//
//  UserFavoritesVC.swift
//  Saloof
//
//  Created by Angela Smith on 8/9/15.
//  Copyright (c) 2015 SNASTek. All rights reserved.
//

import UIKit
import RealmSwift


class UserFavoritesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableview: UITableView!
    // Query using a predicate string
    var favoriteVenues = Realm().objects(FavoriteVenue).filter("\(Constants.realmFilterFavorites) = \(1)")
    
    
    /* -----------------------  VIEW CONTROLLER  METHODS --------------------------- */
    
    
    override func viewWillAppear(animated: Bool) {
        // Remove text and leave back chevron
        self.navigationController?.navigationBar.topItem?.title = ""
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.rowHeight = 105
        let image = UIImage(named: "navBarLogo")
        //navigationItem.titleView = UIImageView(image: image)
        var homeButton =  UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        homeButton.frame = CGRectMake(0, 0, 100, 40) as CGRect
        homeButton.setImage(image, forState: UIControlState.Normal)
        homeButton.addTarget(self, action: Selector("returnHome"), forControlEvents: UIControlEvents.TouchUpInside)
        navigationItem.titleView = homeButton
    }
    
    func returnHome() {
        println("User wants to return home")
        self.performSegueWithIdentifier("returnHomeFromFavorites", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /* -----------------------  TABLEVIEW  METHODS --------------------------- */
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.favoriteVenues.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:FavoritesCell = tableView.dequeueReusableCellWithIdentifier("favoritesCell") as! FavoritesCell
        let venue: FavoriteVenue = favoriteVenues[indexPath.row]
        var image = UIImage()
        if venue.hasImage {
            image = venue.image!
        } else {
            image = UIImage(named: "redHen")!
        }
        cell.setUpCell(venue.name, phone: venue.phone, image: image)
        cell.setUpLikesBar(venue.likes, favorites: venue.favorites, price: venue.priceTier, distance: venue.distance)
        return cell
    }
    
    // Header Cell
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCellWithIdentifier("favHeaderCell") as! FavoriteHeaderCell
        return headerCell
    }
    
    /* -----------------------  SEGUE --------------------------- */
    
    // Pass the selected restaurant object to the detail view
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "restaurantDetailSegue" {
            if let indexPath = self.tableview.indexPathForSelectedRow() {
                var venue: FavoriteVenue = favoriteVenues[indexPath.row]
                let destinationVC = segue.destinationViewController as! VenueDetailVC
                destinationVC.favVenue = venue
                destinationVC.isFavorite = true
            }
        }
    }
    
    @IBAction func shouldPushToSavedDeal(sender: AnyObject) {
        // Check to make sure we have a saved deal
        let realm = Realm()
        var savedDeal = realm.objects(SavedDeal).first
        if (savedDeal != nil) {
            let valid = checkDealIsValid(savedDeal!)
            if valid {
                let storyboard = UIStoryboard(name: "User", bundle: NSBundle.mainBundle())
                let dealsVC: VenueDealsVC = storyboard.instantiateViewControllerWithIdentifier("userDealsVC") as! VenueDealsVC
                dealsVC.loadSingleDeal = true
                dealsVC.setUpForSaved = true
                dealsVC.savedDeal = savedDeal!
                navigationController?.pushViewController(dealsVC, animated: true)
            } else {
                 alertUser("No Deal", message: "Either your deal expired, or you haven't saved one.")
            }
        } else {
            alertUser("No Deal", message: "Either your deal expired, or you haven't saved one.")
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

    
    
    
}
