//
//  W2GLocationDetailed.swift
//  Where2Go
//
//  Created by Daliso Zuze on 30/11/2015.
//  Copyright © 2015 Daliso Zuze. All rights reserved.
//

import Foundation
import CoreData

struct W2GLocationDetailed {
    
    var w2gLocation = W2GLocation(dictionary: nil)
    
    var phoneNumber: String?
    var address:[String]?
    var websiteAddress:String?
    var coverPhoto:Photo?
    var photos:[Photo]?
    var userTips:[String]?
    var openingHours:[[String:String]]?
    
    init(location: W2GLocation, dictionary: [String : AnyObject]) {
        w2gLocation = location
    }

}