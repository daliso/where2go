//
//  W2GLocation.swift
//  Where2Go
//
//  Created by Daliso Zuze on 28/11/2015.
//  Copyright (c) 2015 Daliso Zuze. All rights reserved.
//

import Foundation

struct W2GLocation {

    var venueID = ""
    var venueName = ""
    var latitude:Float = 0.0
    var longitude:Float = 0.0
    
    init(dictionary: [String : AnyObject]?) {
        if let _ = dictionary {
            venueID = dictionary![FoursquareAPIClient.JSONResponseKeys.venueID] as! String
            venueName = dictionary![FoursquareAPIClient.JSONResponseKeys.venueName] as! String
            latitude = dictionary![FoursquareAPIClient.JSONResponseKeys.Latitude] as! Float
            longitude = dictionary![FoursquareAPIClient.JSONResponseKeys.Longitude] as! Float
        }
    }
    
    static func W2GLocationsFromResults(results: [[String : AnyObject]]) -> [W2GLocation] {
        var w2gLocations = [W2GLocation]()
        for result in results {
            w2gLocations.append(W2GLocation(dictionary: result))
        }
        return w2gLocations
    }
}





