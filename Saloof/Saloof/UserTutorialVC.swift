//
//  UserTutorialVC.swift
//  Saloof
//
//  Created by Angela Smith on 8/24/15.
//  Copyright (c) 2015 SNASTek. All rights reserved.
//

import UIKit
import Koloda
import pop

private var numberOfCards: UInt = 4

class UserTutorialVC: UIViewController, KolodaViewDataSource, KolodaViewDelegate {
    
    @IBOutlet var rejectBtn: UIImageView!
    @IBOutlet var favBtn: UIImageView!
    @IBOutlet weak var kolodaView: KolodaView!
    let seconds = 2.5
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let image = UIImage(named: "navBarLogoTut")
        navigationItem.titleView = UIImageView(image: image)
        kolodaView.dataSource = self
        kolodaView.delegate = self
        
        self.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
        swipeRight()
        
    }
    override func viewWillAppear(animated: Bool) {
        navigationController!.navigationBar.barTintColor = UIColor(red:0.46, green:0.21, blue:0.13, alpha:1)
    }
    
    // This method creates a break between the tableview updating and returning a new deal to add to the view
    func swipeRight() {
        let timeDelay = seconds * Double(NSEC_PER_SEC)
        var dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(timeDelay))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            self.kolodaView.swipe(SwipeResultDirection.Right)
            self.swipeleft()
        })
    }
    
    func swipeleft() {
        let timeDelay = seconds * Double(NSEC_PER_SEC)
        var dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(timeDelay))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            self.kolodaView.swipe(SwipeResultDirection.Left)
            self.swipeTap1()
        })
    }
    
    func swipeTap1() {
        let timeDelay = seconds * Double(NSEC_PER_SEC)
        var dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(timeDelay))
        favBtn.image = UIImage(named: "tutorialFavBut")
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            self.kolodaView.swipe(SwipeResultDirection.Right)
            self.swipeTap2()
        })
    }
    // tutorialFavBut tutorialFavButUn  tutorialRejectBtn  tutorialRejectBtnUn
    func swipeTap2() {
        favBtn.image = UIImage(named: "tutorialFavButUn")
        rejectBtn.image = UIImage(named: "tutorialRejectBtn")
        let timeDelay = seconds * Double(NSEC_PER_SEC)
        var dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(timeDelay))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            self.kolodaView.swipe(SwipeResultDirection.Left)
            self.rejectBtn.image = UIImage(named: "tutorialRejectBtnUn")
            self.swipeRight()
        })
    }
    
    
    //MARK: IBActions
    
    @IBAction func closeTutorial(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)

    }
    
    //MARK: KolodaViewDataSource
    func kolodaNumberOfCards(koloda: KolodaView) -> UInt {
        return numberOfCards
    }
    
    func kolodaViewForCardAtIndex(koloda: KolodaView, index: UInt) -> UIView {
        return UIImageView(image: UIImage(named: "swipeCard\(index + 1)"))
    }
    
    func kolodaViewForCardOverlayAtIndex(koloda: KolodaView, index: UInt) -> OverlayView? {
        return NSBundle.mainBundle().loadNibNamed("CardOverlayView",
            owner: self, options: nil)[0] as? OverlayView
    }
    
    //MARK: KolodaViewDelegate
    
    func kolodaDidSwipedCardAtIndex(koloda: KolodaView, index: UInt, direction: SwipeResultDirection) {
        //Example: loading more cards
        if index >= 3 {
            numberOfCards = 6
            kolodaView.reloadData()
        }
    }
    
    func kolodaDidRunOutOfCards(koloda: KolodaView) {
        //Example: reloading
        kolodaView.resetCurrentCardNumber()
    }
    
    func kolodaDidSelectCardAtIndex(koloda: KolodaView, index: UInt) {
    }
    
    func kolodaShouldApplyAppearAnimation(koloda: KolodaView) -> Bool {
        return true
    }
    
    func kolodaShouldMoveBackgroundCard(koloda: KolodaView) -> Bool {
        return true
    }
    
    func kolodaShouldTransparentizeNextCard(koloda: KolodaView) -> Bool {
        return true
    }
    
    func kolodaBackgroundCardAnimation(koloda: KolodaView) -> POPPropertyAnimation? {
        return nil
    }
    
}

