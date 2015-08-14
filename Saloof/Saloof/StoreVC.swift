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
    
    let productIdenifiers = Set(["com.snastek.tier1", "com.snastek.tier2", "com.snastek.tier3", "com.snastek.tier4"])
    var product: SKProduct?
    var productsArray = Array<SKProduct>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage(named: "navBarLogo")
        navigationItem.titleView = UIImageView(image: image)
        
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        requestProductData()
        
    }
    
    func requestProductData(){
        
        if SKPaymentQueue.canMakePayments(){
            let request = SKProductsRequest(productIdentifiers: self.productIdenifiers as Set<NSObject>)
            request.delegate = self
            request.start()
        }else {
            var alert = UIAlertController(title: "In-App Purchases Not Enabled", message: "Please enable In App Purchase in Settings", preferredStyle: UIAlertControllerStyle.Alert)
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
    
    func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!) {
        
        var products = response.products // conains array of all the products
        
        if (products.count != 0){
            for var i = 0; i < products.count; i++ {
                self.product = products[i] as? SKProduct
                self.productsArray.append(product!)
                tableView.reloadData()
            }
            
        }else{
            println("No products found")
        }
        
        products = response.invalidProductIdentifiers
        
        for product in products {
            println("Product not found: \(product)")
        }
        
    }
    
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
        
        for transaction in transactions as! [SKPaymentTransaction] {
            
            switch transaction.transactionState {
                
            case SKPaymentTransactionState.Purchased:
                println("Transaction Approved")
                println("Product Identifier: \(transaction.payment.productIdentifier)")
                self.deliverProduct(transaction)
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                
            case SKPaymentTransactionState.Failed:
                println("Transation Failed")
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
            default:
                break
            }
        }
    }
    
    func deliverProduct(transaction:SKPaymentTransaction) {
        
        
        func saveTransation(price: Int){
            
            var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            //APICalls.uploadBalance(price, restID: prefs.stringForKey("restID")!)
            APICalls.uploadBalance(price, restID: prefs.stringForKey("restID")!, completion: { result in
                if result {
                    println("Credits updated")
                }
            })
        }
        
        if transaction.payment.productIdentifier == "com.snastek.tier1" {
            
            println("$10 purchased")
            saveTransation(50)
            // Unlock feature or add credits
        }else if transaction.payment.productIdentifier == "com.snastek.tier2" {
            
            println("$20 purchased")
            saveTransation(100)
            // Add credits
            
        }else if transaction.payment.productIdentifier == "com.snastek.tier3" {
            
            println("$50 purchased")
            saveTransation(250)
            
            // Unlock feature or add credits
        }else if transaction.payment.productIdentifier == "com.snastek.tier4" {
            
            println("$75 purchased")
            saveTransation(375)
            
            // Add credits
            
        }
        
        
        
    }
    
    
    // Table view methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productsArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as! UITableViewCell
        
        cell.textLabel?.text = productsArray[indexPath.row].localizedTitle
        cell.detailTextLabel?.text = "$\(productsArray[indexPath.row].price)"
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        println(productsArray[indexPath.row].localizedTitle)
        let payment = SKPayment(product: productsArray[indexPath.row])
        SKPaymentQueue.defaultQueue().addPayment(payment)
        
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}
