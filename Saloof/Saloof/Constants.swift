//
//  Constants.swift
//  Saloof
//
//  Created by Angela Smith on 7/22/15.
//  Copyright (c) 2015 Angela Smith. All rights reserved.
//

import Foundation

struct Constants {
    
    // Restaurant Constants
    static let restId = "id"
    static let restName = "name"
    static let restContactObject = "contact"
    static let restContactPhone = "formattedPhone"
    static let restLocationObject = "lat"
    static let restLat = "lat"
    static let restLon = "lng"
    static let restDistance = "distance"
    static let restAddressArray = "address"
    static let restUrl = "url"
    static let restPriceObject = "price"
    static let restTier = "tier"
    static let restHoursObject = "hours"
    static let restStatus = "status"
    static let restIsOpen = "isOpen"
    static let restPhotoObject = "photos"
    static let restPhotoGroupArray = "groups"
    static let restPhotoItemsArray = "items"
    static let restPhotoId = "id"
    static let restPhotoUrl = "url"
    static let restPhotoPrefix = "prefix"
    static let restPhotoSuffix = "suffix"
    static let restStats = "stats"
    static let restLikes = "likes"
    static let restFavorites = "favorites"
    static let restImageName = "imageName"
    
    
    // Deal constants
    static let dealsArray = "deal"
    static let dealObject = "deals"
    static let dealTier = "tier"
    static let dealTitle = "title"
    static let dealIsDefault = "isDefault"
    static let dealDescription = "description"
    static let dealExpires = "expirationTime"
    static let dealValue = "value"
    static let dealID = "dealId"
    static let dealValid = "validValue"
    // NSUserDefaults
    static let dealDefaults = "Saloof.dealArray"
    static let dealDateFormatter = "yyyy-MM-dd HH:mm:ss"
    
    // Realm Data Objects
    static let sourceTypeFoursquare = "Foursquare"
    static let sourceTypeSaloof = "Saloof"
    static let realmFilterFavorites = "swipeValue"  // 0: not swiped, 1: favorite, 2: rejected  3: Deal only
    
}
