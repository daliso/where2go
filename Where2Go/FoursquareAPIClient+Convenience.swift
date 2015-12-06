//
//  FoursquareAPIClient+Convenience.swift
//  Where2Go
//
//  Created by Daliso Zuze
//  Copyright (c) 2015 Daliso Zuze. All rights reserved.
//

import UIKit
import Foundation


extension FoursquareAPIClient {
    
    func getVenueDetails(venueID: String, completionHandler: (success: Bool, userDataDictionary: [String:AnyObject]?, errorString: String?) -> Void){
        // Fill in the code for extracting details for one particular venue
        
    }
    
    
    func getNearbyLocations(section:String, lat:Double, lon:Double, radius:Double, completionHandler: (success: Bool, userDataDictionary: [String:AnyObject]?, errorString: String?) -> Void) -> Void {
        
        switch Reach().connectionStatus() {
        case .Offline , .Unknown:
            completionHandler(success: false, userDataDictionary: nil, errorString: "Error: No network connection")
        case .Online(.WWAN), .Online(.WiFi):
            let methodArguments = [
                ParameterKeys.FoursquareClientID: Constants.FoursquareClientID,
                ParameterKeys.FoursquareClientSecret: Constants.FoursquareSecret,
                ParameterKeys.FoursquareAPIVersion: Constants.FoursquareAPIVersion,
                ParameterKeys.Section: section,
                ParameterKeys.LatLon: "\(lat),\(lon)",
                ParameterKeys.Radius: radius,
                ParameterKeys.VenuePhotos: Constants.VenuePhotos,
                ParameterKeys.Time: Constants.Time,
                ParameterKeys.Day: Constants.Day
            ]
            
            _ = taskForGETMethod(Methods.Explore, parameters: methodArguments, baseUrl: Constants.BaseURLSecure, dataOffSet: 0, headers: nil) { JSONResult, error in
                
                if let _ = error {
                    completionHandler(success: false, userDataDictionary: nil, errorString: "There was an error getting photos from Flickr: \(error?.userInfo)")
                }
                else {
                    if let userDataDict = JSONResult.valueForKey("response")?.valueForKey("groups") as? [[String:AnyObject]] {
                        
                        let code = JSONResult.valueForKey("meta")!.valueForKey("code") as! Int
                        if code == 200 {
                            completionHandler(success: true, userDataDictionary: userDataDict.first, errorString:nil)
                        }
                        else  if (code - 400) >= 0 && (code - 400) <= 100 {
                            let errorType = JSONResult.valueForKey("meta")!.valueForKey("errorType") as! String
                            let errorDetail = JSONResult.valueForKey("meta")!.valueForKey("errorDetail") as! String
                            let errorMessage = "\(errorType) : \(errorDetail)"
                            
                            completionHandler(success: false, userDataDictionary: nil, errorString: errorMessage)
                        }
                        else {
                            completionHandler(success: false, userDataDictionary: nil, errorString: "There was a problem with the response from Foursquare")
                        }
                    }
                    else {
                        // need to check here if the JSON result contains some known property with an error message
                        completionHandler(success: false, userDataDictionary: nil, errorString: "There was an error getting photos from Flickr, the JSON response did not contain a response key")
                    }
                }
            }
        }
    }

}