//
//  CardView.swift
//  Saloof
//
//  Created by Angela Smith on 8/20/15.
//  Copyright (c) 2015 SNASTek. All rights reserved.
//

import UIKit

extension UIImageView {
    public func imageFromUrl(urlString: String) {
        if let url = NSURL(string: urlString) {
            let request = NSURLRequest(URL: url)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {
                (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                self.image = UIImage(data: data)
            }
        }
    }
}


class CardView: UIView {
    
    @IBOutlet var venueImageView: UIImageView?
    @IBOutlet var venueNameLabel: UILabel?
    @IBOutlet var venuePhoneLabel: UILabel?


}
