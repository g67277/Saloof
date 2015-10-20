//
//  CreateActivityView.swift
//  Saloof
//
//  Created by Nazir Shuqair on 8/11/15.
//  Copyright (c) 2015 SNASTek. All rights reserved.
//

import UIKit

public class CreateActivityView{
    
    class func createView(backgroundColor: UIColor?, frame: CGRect) -> (UIView){
        
        let container = UIView(frame: frame)
        container.backgroundColor = backgroundColor
        container.alpha = 0.7
        
        return container
    }
    
}
