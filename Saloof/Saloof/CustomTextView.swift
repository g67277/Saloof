//
//  CustomTextView.swift
//  Saloof
//
//  Created by Brendan Conron on 12/29/14.
//  Copyright (c) 2014 Brendan Conron. All rights reserved.
//

import UIKit

class CustomTextView: UITextView {
    
    enum VerticalAlignment: Int {
        case Top = 0, Middle, Bottom
    }
    
    var verticalAlignment: VerticalAlignment = .Middle
    
    //override contentSize property and observe using didSet
    override var contentSize: CGSize {
        didSet {
            let textView = self
            let height = textView.bounds.size.height
            let contentHeight = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: CGFloat(FLT_MAX))).height
            var topCorrect: CGFloat = 0.0
            switch(self.verticalAlignment){
            case .Top:
                textView.contentOffset = CGPointZero //set content offset to top
            case .Middle:
                topCorrect = (height - contentHeight * textView.zoomScale)/2.0
                topCorrect = topCorrect < 0 ? 0 : topCorrect
                textView.contentOffset = CGPoint(x: 0, y: -topCorrect)
            case .Bottom:
                topCorrect = textView.bounds.size.height - contentHeight
                topCorrect = topCorrect < 0 ? 0 : topCorrect
                textView.contentOffset = CGPoint(x: 0, y: -topCorrect)
            }
            if contentHeight >= height { //if the contentSize is greater than the height
                topCorrect = contentHeight - height //set the contentOffset to be the
                topCorrect = topCorrect < 0 ? 0 : topCorrect //contentHeight - height of textView
                textView.contentOffset = CGPoint(x: 0, y: topCorrect)
            }
        }
    }
    
    // MARK: - UIView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size = self.contentSize //forces didSet to be called
        self.contentSize = size
    }
    
}