//
//  LikedVenue.swift
//  Saloof
//
//  Created by Angela Smith on 8/10/15.
//  Copyright (c) 2015 SNASTek. All rights reserved.
//

import RealmSwift

class LikedVenue: Object {
    
    dynamic var likedId = ""
    
    override class func primaryKey() -> String {
        return "likedId"
    }
}
