//
//  CreateActivityView.swift
//  Saloof
//
//  Created by Nazir Shuqair on 8/11/15.
//  Copyright (c) 2015 SNASTek. All rights reserved.
//

import UIKit

public class CreateActivityView{
    
    class func createView(backgroundColor: UIColor?) -> (UIView){
        
        var container = UIView(frame: CGRectMake(0, 0, 150, 150))
        container.roundCorners(.AllCorners, radius: 14)
        container.backgroundColor = backgroundColor
        container.alpha = 0.5
        
        return container
    }
    
}
