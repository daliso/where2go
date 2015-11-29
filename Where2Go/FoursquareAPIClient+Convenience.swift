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
    
    func getNearbyLocations(section:String, lat:Double, lon:Double, radius:Double, completionHandler: (success: Bool, userDataDictionary: [String:AnyObject]?, errorString: String?) -> Void) -> Void {
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
                completionHandler(success: false, userDataDictionary: nil, errorString: "There was an error getting photos from Flickr")
            }
            else {
                if let userDataDict = JSONResult.valueForKey("response")?.valueForKey("groups") as? [[String:AnyObject]] {
                    completionHandler(success: true, userDataDictionary: userDataDict.first, errorString:nil)

                }
                else {
                    // need to check here if the JSON result contains some known property with an error message
                    completionHandler(success: false, userDataDictionary: nil, errorString: "There was an error getting photos from Flickr, the JSON response did not contain a response key")
                }
            }
        }
    }

}
    
    
    /*
    func getRandomPhotos(lat:Double, lon:Double, completionHandler: (success: Bool, userDataDictionary: NSArray?, errorString: String?) -> Void) {
        
        if IJReachability.isConnectedToNetwork() {
            
            var methodArguments = [
                "method": Methods.METHOD_NAME,
                "api_key": Constants.API_KEY,
                "bbox": createBoundingBoxString(lat,longitude: lon),
                "safe_search": Constants.SAFE_SEARCH,
                "extras": Constants.EXTRAS,
                "format": Constants.DATA_FORMAT,
                "nojsoncallback": Constants.NO_JSON_CALLBACK
            ]
            
            _ = taskForGETMethod("", parameters: methodArguments, baseUrl: Constants.BASE_URL, dataOffSet: 0, headers: nil) { JSONResult, error in
                
                if let _ = error {
                    completionHandler(success: false, userDataDictionary: nil, errorString: "There was an error getting photos from Flickr")
                }
                else {
                    
                    if let userDataDict = JSONResult.valueForKey("photos") as? NSDictionary {
                        
                        let numPages = userDataDict.valueForKey("pages")!.integerValue!
                        let pageLimit = min(numPages, 40)
                        let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
                        
                        methodArguments["page"] = "\(randomPage)"
                        
                        _ = self.taskForGETMethod("", parameters: methodArguments, baseUrl: Constants.BASE_URL, dataOffSet: 0, headers: nil) { JSONResult, error in
                            
                            if let _ = error {
                                completionHandler(success: false, userDataDictionary: nil, errorString: "There was an error getting photos from a random page")
                            }
                            else {
                                if let userDataDict = JSONResult.valueForKey("photos") as? NSDictionary {
                                    
                                    let photosDict = userDataDict.valueForKey("photo") as? NSArray
                                    
                                    completionHandler(success: true, userDataDictionary: photosDict!, errorString: nil)
                                }
                                else {
                                    completionHandler(success: false, userDataDictionary: nil, errorString: "There was an error getting photos from Flckr, the JSON response did not contain a photos key")
                                }
                            }
                        }
                    }
                    else {
                        completionHandler(success: false, userDataDictionary: nil, errorString: "There was an error getting photos from Flickr, the JSON response did not contain a photos key")
                    }
                }
            }
        }
        else {
            completionHandler(success: false, userDataDictionary: nil, errorString: "You are not connected to the Internet")
        }
    }
    
    func createBoundingBoxString(latitude:Double, longitude:Double) -> String {
        
        /* Fix added to ensure box is bounded by minimum and maximums */
        let bottom_left_lon = max(longitude - Constants.BOUNDING_BOX_HALF_WIDTH, Constants.LON_MIN)
        let bottom_left_lat = max(latitude - Constants.BOUNDING_BOX_HALF_HEIGHT, Constants.LAT_MIN)
        let top_right_lon = min(longitude + Constants.BOUNDING_BOX_HALF_HEIGHT, Constants.LON_MAX)
        let top_right_lat = min(latitude + Constants.BOUNDING_BOX_HALF_HEIGHT, Constants.LAT_MAX)
        
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }
    */