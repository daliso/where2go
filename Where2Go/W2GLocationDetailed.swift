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
    var openingHours:[String]?
    var websiteAddress:String?
    var coverPhoto:String?
   // var userPhotos:[Photo]?
    var userTips:[String]?
    var rating:Double?
    // var reviews:[Review]
    
    init(dictionary: [String : AnyObject]){
        name = dictionary[FoursquareAPIClient.JSONResponseKeys.venueName] as! String
        phoneNumber = dictionary[FoursquareAPIClient.JSONResponseKeys.formattedPhone] as? String
        address = dictionary[FoursquareAPIClient.JSONResponseKeys.formattedAddress] as? [String]
        openingHours = dictionary[FoursquareAPIClient.JSONResponseKeys.hours] as? [String]
        websiteAddress = dictionary[FoursquareAPIClient.JSONResponseKeys.venueWebsiteAddress] as? String
        coverPhoto = dictionary[FoursquareAPIClient.JSONResponseKeys.bestPhoto] as? String
        //    userPhotos = dictionary[""] as? [Photo]
        rating = dictionary[FoursquareAPIClient.JSONResponseKeys.venueRating] as? Double
    }
    
    static func W2GLocationsDetailedFromResults(results: [[String : AnyObject]]) -> [W2GLocationDetailed] {
        var w2gLocationsDetailed = [W2GLocationDetailed]()
        for result in results {
            w2gLocationsDetailed.append(W2GLocationDetailed(dictionary: result))
        }
        return w2gLocationsDetailed
    }
}