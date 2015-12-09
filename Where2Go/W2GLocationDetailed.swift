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
    
    var name:String
    var phoneNumber: String?
    var address:[String]?
    var openingHours:[String:String]?
    var websiteAddress:String?
    var coverPhoto:Photo?
    var userPhotos:[Photo]?
    var userTips:[String]?
    var rating:Double?
    // var reviews:[Review]
    
    init(dictionary: [String : AnyObject]){
        name = dictionary[""] as! String
        phoneNumber = dictionary[""] as? String
        address = dictionary[""] as? [String]
        openingHours = dictionary[""] as? [String:String]
        websiteAddress = dictionary[""] as? String
        coverPhoto = dictionary[""] as? Photo
        userPhotos = dictionary[""] as? [Photo]
        rating = dictionary[""] as? Double
    }
    
    static func W2GLocationsDetailedFromResults(results: [[String : AnyObject]]) -> [W2GLocationDetailed] {
        var w2gLocationsDetailed = [W2GLocationDetailed]()
        for result in results {
            w2gLocationsDetailed.append(W2GLocationDetailed(dictionary: result))
        }
        return w2gLocationsDetailed
    }
}