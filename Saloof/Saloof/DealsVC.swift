//
//  DealsVC.swift
//  Saloof
//
//  Created by Nazir Shuqair on 7/18/15.
//  Copyright (c) 2015 SNASTek. All rights reserved.
//

import UIKit
import RealmSwift
import AssetsLibrary

class DealsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var addBtn: UIBarButtonItem!
    @IBOutlet weak var dealsList: UITableView!
    let prefs: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    var savedDealsArray = Realm().objects(BusinessDeal).sorted("value", ascending: true)
    var dealsArray : [BusinessDeal] = []
    var realm = Realm()
    var topTier = 0
    var defaultImg = UIImage()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        var data = Realm().objectForPrimaryKey(ProfileModel.self, key: prefs.stringForKey("restID")!)
        if savedDealsArray.count > 0{
            dealsArray.removeAll(keepCapacity: true)
            for deal in savedDealsArray{
                if deal.restaurantID == prefs.stringForKey("restID"){
                    dealsArray.append(deal)
                }
            }
        }
        
        dealsList.reloadData()
        var test = dealsArray.count
        if dealsArray.count == 10 {
            addBtn.enabled = false
        }else{
            addBtn.enabled = true
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage(named: "navBarLogo")
        navigationItem.titleView = UIImageView(image: image)
        
        var data = Realm().objectForPrimaryKey(ProfileModel.self, key: prefs.stringForKey("restID")!)
        
        var path = data?.imgUri
        if path != nil{
            var imgURL = NSURL(string: path!)
            getUIImagefromAsseturl(imgURL!)
        }
        
    }
    
    func getUIImagefromAsseturl (url: NSURL) {
        var asset = ALAssetsLibrary()
        
        asset.assetForURL(url, resultBlock: { asset in
            if let ast = asset {
                let assetRep = ast.defaultRepresentation()
                let iref = assetRep.fullResolutionImage().takeUnretainedValue()
                let image = UIImage(CGImage: iref)
                dispatch_async(dispatch_get_main_queue(), {
                    self.defaultImg = image!
                })
            }
            }, failureBlock: { error in
                println("Error: \(error)")
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        dealsList.reloadData()
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let IVC = segue.destinationViewController as! DealDetailsVC
        
        if segue.identifier == "toDetails" {
            
            var selectedItem = dealsArray[(dealsList.indexPathForSelectedRow()?.row)!]
            
            IVC.tier = (dealsList.indexPathForSelectedRow()?.row)!
            IVC.dealTitle = selectedItem.title
            IVC.desc = selectedItem.desc
            IVC.value = selectedItem.value
            IVC.hours = selectedItem.timeLimit
            IVC.dealID = selectedItem.id
            IVC.editingMode = true
            IVC.img = defaultImg
            
        }else if segue.identifier == "toAdd"{
            IVC.img = defaultImg
            
        }
        
    }
    
    
    @IBAction func onClick(_sender : UIButton?){
        
        if _sender?.tag == 0{
            
            // Publish deals here
            var alertView:UIAlertView = UIAlertView()
            alertView.title = "Published!"
            alertView.message = "You are now live, get ready for the swarms"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        }
    }
    
    
    //Mark# Tableview methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dealsArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:DealsCell = tableView.dequeueReusableCellWithIdentifier("dealCell") as! DealsCell
        
        // load items from deal array here
        
        cell.refreshCell(dealsArray[indexPath.row].title, desc: dealsArray[indexPath.row].desc, time: dealsArray[indexPath.row].timeLimit, value: "$\(dealsArray[indexPath.row].value) value", tier: indexPath.row + 1, img: defaultImg)
        
        //cell.refreshCell("10% off Drinks", desc: "10% off drinks when you buy anything from the lunch menu", time: 2, value: "Value: $0.80")
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

