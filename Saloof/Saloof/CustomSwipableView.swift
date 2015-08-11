//
//  CustomSwipableView.swift
//  Saloof
//
//  Created by Angela Smith on 8/11/15.
//  Copyright (c) 2015 SNASTek. All rights reserved.
//

import UIKit
import Koloda

class CustomSwipableView: KolodaView {

    func frameForCardAtIndex(index: UInt) -> CGRect {
        if index == 0 {
            let bottomOffset:CGFloat = 0
            let topOffset:CGFloat = 10
            let xOffset:CGFloat = 50
            let width = CGRectGetWidth(self.frame ) - 10 - 10
            let height = width * 1.25
            let yOffset:CGFloat = topOffset
            let frame = CGRect(x: xOffset, y: yOffset, width: width, height: height)
            
            return frame
        } else if index == 1 {
            return CGRect(x: -self.bounds.width * 0.5 , y: 0, width: self.bounds.width * 2, height: self.bounds.width * 2 * 1.5)
        }
        return CGRectZero
    }


}
