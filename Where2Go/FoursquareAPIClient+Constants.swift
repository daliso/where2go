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
        static let venueName = "name"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let contact = "contact"
        static let formattedPhone = "formattedPhone"
        static let location = "location"
        static let formattedAddress = "formattedAddress"
        static let venueWebsiteAddress = "url"
        static let venueRating = "rating"
        static let bestPhoto = "bestPhoto"
        static let bestPhotoPrefix = "prefix"
        static let bestPhotoSuffix = "suffix"
        static let hours = "hours"
        static let timeframes = "timeframes"
        
        static let StatusMessage = "meta"
    }
    
    // MARK: - Constants
    struct Constants {
        // MARK: API Key
        static let FoursquareClientID:String = "D41FV1BZ1MZ0U2H2AUREHU24HE3IILD3IGPCYXCIB1OWYG1E"
        static let FoursquareSecret:String = "BTU2AV22ZBPNQODCOOXKZJEPNEFYAKFBHA4HCU4P5BXZWXZJ"
        static let FoursquareAPIVersion:String = "20130815"
        static let VenuePhotos = 1
        static let Time = "any"
        static let Day = "any"
        
        // MARK: URLs
        static let BaseURL : String = "http://api.foursquare.com/v2/venues"
        static let BaseURLSecure : String = "https://api.foursquare.com/v2/venues"
    }
    
    struct Methods {
        // MARK: Account
        static let Search = "search"
        static let Explore = "explore"
    }
    
    struct ParameterKeys {
        static let FoursquareClientID:String = "client_id"
        static let FoursquareClientSecret:String = "client_secret"
        static let FoursquareAPIVersion:String = "v"
        static let LatLon:String = "ll"
        static let Section:String = "section"
        static let Time:String = "time"
        static let Day:String = "day"
        static let VenuePhotos:String = "venuePhotos"
        static let Radius:String = "radius"
    }

}