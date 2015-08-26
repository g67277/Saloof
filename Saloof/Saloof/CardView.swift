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
    @IBOutlet var sourceImageView: UIImageView?
    @IBOutlet var venueNameLabel: UILabel?
    @IBOutlet var venuePhoneLabel: UILabel?
    
    func setImageWithURL(imgAddress: String) {
        venueImageView?.setImageCacheWithAddress(imgAddress, placeHolderImage: UIImage (named: "placeholder")!)
    }

    
    // Relay out subviews for auto constraints
    override func layoutSublayersOfLayer(layer: CALayer!) {
        super.layoutSublayersOfLayer(layer)
        venueImageView!.roundCorners((UIRectCorner.TopLeft|UIRectCorner.TopRight), radius: 14)
        venuePhoneLabel!.roundCorners((.BottomLeft  | .BottomRight), radius: 14)
    }


}
