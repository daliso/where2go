//
//  UdacityAPIConstants.swift
//  On The Map Udacity
//
//  Created by Daliso Zuze on 17/08/2015.
//  Copyright (c) 2015 Daliso Zuze. All rights reserved.
//

extension FoursquareAPIClient {
    
    
    // MARK: - JSON Response Keys
    struct JSONResponseKeys {
        // MARK: Venues
        static let venueID = "venueID"
        static let venueName = "venueName"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        
        static let StatusMessage = "stat"
    }
    
    // MARK: - Constants
    struct Constants {
        // MARK: API Key
        static let FoursquareClientID : String = "D41FV1BZ1MZ0U2H2AUREHU24HE3IILD3IGPCYXCIB1OWYG1E"
        static let FoursquareSecret : String = "BTU2AV22ZBPNQODCOOXKZJEPNEFYAKFBHA4HCU4P5BXZWXZJ"
        
        // MARK: URLs
        static let BaseURL : String = "http://api.foursquare.com/v2/"
        static let BaseURLSecure : String = "https://api.foursquare.com/v2/"
        
    }
    
    /*
    
    // MARK: - Methods
    struct Methods {
        // MARK: Account
        static let Session = "session"
        static let Account = "account"
        static let StudentLocations = "classes/StudentLocation"
    }
    
    // MARK: - JSON Body Keys
    struct JSONBodyKeys {
        
        static let Username = "username"
        static let Password = "password"
        
        static let UniqueKey = "uniqueKey"
        static let FirstName  = "firstName"
        static let LastName  = "lastName"
        static let MapString  = "mapString"
        static let MediaURL  = "mediaURL"
        static let Latitude  = "latitude"
        static let Longitude = "longitude"
        
        static let fbToken = "access_token"
    }

    */

}