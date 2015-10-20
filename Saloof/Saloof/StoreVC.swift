//
//  StoreVC.swift
//  Saloof
//
//  Created by Nazir Shuqair on 7/15/15.
//  Copyright (c) 2015 SNASTek. All rights reserved.
//

import UIKit
import StoreKit

class StoreVC: UIViewController, UITableViewDataSource, UITableViewDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    @IBOutlet weak var tableView: UITableView!
    
    
    let productIdenifiers = Set(["com.nazir.tier1", "com.nazir.tier2", "com.nazir.tier3", "com.nazir.tier4"])
    var product: SKProduct?
    var productsArray = Array<SKProduct>()
    var bought = false
    
    var containerView = UIView()
    var aIView = CustomActivityView(frame: CGRect (x: 0, y: 100, width: 100, height: 100), color: UIColor.whiteColor(), size: CGSize(width: 100, height: 100))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage(named: "navBarLogo")
        navigationItem.titleView = UIImageView(image: image)
        containerView = CreateActivityView.createView(UIColor.blackColor(), frame: self.view.frame)

        
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        requestProductData()
        
    }
    func requestProductData(){
        
        if SKPaymentQueue.canMakePayments(){
            let request = SKProductsRequest(productIdentifiers: self.productIdenifiers as Set<String>)
            request.delegate = self
            request.start()
        }else {
            let alert = UIAlertController(title: "In-App Purchases Not Enabled", message: "Please enable In App Purchase in Settings", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Settings", style: UIAlertActionStyle.Default, handler: { alertAction in
                alert.dismissViewControllerAnimated(true, completion: nil)
                
                let url: NSURL? = NSURL(string: UIApplicationOpenSettingsURLString)
                if url != nil
                {
                    UIApplication.sharedApplication().openURL(url!)
                }
                
            }))
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { alertAction in
                alert.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        
        var products = response.products // conains array of all the products
        
        if (products.count != 0){
            for var i = 0; i < products.count; i++ {
                self.product = products[i]
                //self.product = products[i] as? SKProduct
                self.productsArray.append(product!)
                tableView.reloadData()
            }
            
        }else{
            print("No products found", terminator: "")
        }
        
        // TO DO handle errors
        //products = response.invalidProductIdentifiers
        
        //for _ in products {
            //println("Product not found: \(product)")
        //}
        
    }
    
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            
            switch transaction.transactionState {
                
            case SKPaymentTransactionState.Purchased:
                print("Transaction Approved", terminator: "")
                print("Product Identifier: \(transaction.payment.productIdentifier)", terminator: "")
                self.deliverProduct(transaction)
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                
            case SKPaymentTransactionState.Failed:
                print("Transation Failed", terminator: "")
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                aIView.startAnimation()
                containerView.removeFromSuperview()
            default:
                break
            }
        }
    }
    
    func deliverProduct(transaction:SKPaymentTransaction) {

        
        if transaction.payment.productIdentifier == "com.nazir.tier1" {
            
            print("$10 purchased", terminator: "")
            saveTransation(50)
            // Unlock feature or add credits
        }else if transaction.payment.productIdentifier == "com.nazir.tier2" {
            
            print("$20 purchased", terminator: "")
            saveTransation(100)
            // Add credits
            
        }else if transaction.payment.productIdentifier == "com.nazir.tier3" {
            
            print("$50 purchased", terminator: "")
            saveTransation(250)
            
            // Unlock feature or add credits
        }else if transaction.payment.productIdentifier == "com.nazir.tier4" {
            
            print("$75 purchased", terminator: "")
            saveTransation(375)
            
            // Add credits
            
        }
        
        
        
    }
    
    func saveTransation(price: Int){
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let restId = prefs.stringForKey("restID")!
        let token = prefs.stringForKey("TOKEN")!
        print("about to upload \(price) to id: \(restId)", terminator: "")
        if bought{
            bought = false
            APICalls.uploadBalance(Double(price), restID: restId.uppercaseString, token: token)
        }
        aIView.stopAnimation()
        containerView.removeFromSuperview()
    }
    
    
    // Table view methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productsArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell!
        cell.textLabel?.text = productsArray[indexPath.row].localizedTitle
        cell.detailTextLabel?.text = "$\(productsArray[indexPath.row].price)"
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let win:UIWindow = UIApplication.sharedApplication().delegate!.window!!
        aIView.center = containerView.center
        containerView.addSubview(aIView)
        containerView.center = self.view.center
        win.addSubview(containerView)
        aIView.startAnimation()
        //println(productsArray[indexPath.row].localizedTitle)
        bought = true
        let payment = SKPayment(product: productsArray[indexPath.row])
        SKPaymentQueue.defaultQueue().addPayment(payment)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        SKPaymentQueue.defaultQueue().removeTransactionObserver(self)
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}
