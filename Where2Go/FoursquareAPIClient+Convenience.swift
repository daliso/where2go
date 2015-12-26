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
    
    func getVenueDetails(venueID: String, completionHandler: (success: Bool, locationDetails:W2GLocationDetailed?, errorString: String?) -> Void){
        
        switch Reach().connectionStatus() {
        case .Offline , .Unknown:
            completionHandler(success: false, locationDetails: nil, errorString: "Error: No network connection")
        case .Online(.WWAN), .Online(.WiFi):
            print("getting details for a particular venue")
            let methodArguments = [
                ParameterKeys.FoursquareClientID: Constants.FoursquareClientID,
                ParameterKeys.FoursquareClientSecret: Constants.FoursquareSecret,
                ParameterKeys.FoursquareAPIVersion: Constants.FoursquareAPIVersion,
            ]
            
            _ = taskForGETMethod(venueID, parameters: methodArguments, baseUrl: Constants.BaseURLSecure, dataOffSet: 0, headers: nil) { JSONResult, error in
                
                if let _ = error {
                    completionHandler(success: false, locationDetails: nil, errorString: "There was an error getting the location details from Foursquare: \(error?.userInfo)")
                }
                else {
                    if let venueDict = JSONResult.valueForKey("response")?.valueForKey("venue") as? [String:AnyObject] {
                        
                        let code = JSONResult.valueForKey("meta")!.valueForKey("code") as! Int
                        if code == 200 {
                            
                            let venueName = venueDict[FoursquareAPIClient.JSONResponseKeys.venueName] as! String
                            let venuePhoneNumber = (venueDict[FoursquareAPIClient.JSONResponseKeys.contact] as! [String:AnyObject])[FoursquareAPIClient.JSONResponseKeys.formattedPhone] as? String ?? "No Phone Number"
                            let venueAddress = (venueDict[FoursquareAPIClient.JSONResponseKeys.location] as! [String:AnyObject])[FoursquareAPIClient.JSONResponseKeys.formattedAddress] as? [String] ?? ["No address information"]
                            
                            let venueWebsiteAddress = venueDict[FoursquareAPIClient.JSONResponseKeys.venueWebsiteAddress] as? String ?? "No Website Address Available"
                            let venueRating = venueDict[FoursquareAPIClient.JSONResponseKeys.venueRating] as? Double ?? 0.0
                            
                            
                            var openHoursData = [String]()

                            if let hours = venueDict[FoursquareAPIClient.JSONResponseKeys.hours] as? [String:AnyObject] {
                                
                                let venueOpeningHours = hours[FoursquareAPIClient.JSONResponseKeys.timeframes] as! [[String:AnyObject]]
                                
                                for timeframe in venueOpeningHours {
                                    let days = timeframe["days"] as! String
                                    openHoursData.append("\(days):")
                                    
                                    let openTimesPerDay = timeframe["open"] as! [[String:AnyObject]]
                                    for openTime in openTimesPerDay {
                                        openHoursData.append(openTime["renderedTime"] as! String)
                                    }
                                }

                            } else {
                                openHoursData.append("No Opening Hours Data Available")
                            }
                            
                            var venueCoverPhoto = ""
                            
                            if let bestPhoto = venueDict[FoursquareAPIClient.JSONResponseKeys.bestPhoto] as? [String:AnyObject] {
                                venueCoverPhoto = "\(bestPhoto[FoursquareAPIClient.JSONResponseKeys.bestPhotoPrefix]!)original\(bestPhoto[FoursquareAPIClient.JSONResponseKeys.bestPhotoSuffix]!)"
                            }
                           
                            
                            let locationDetails:[String:AnyObject] = [
                                FoursquareAPIClient.JSONResponseKeys.venueName:venueName,
                                FoursquareAPIClient.JSONResponseKeys.formattedPhone : venuePhoneNumber,
                                FoursquareAPIClient.JSONResponseKeys.formattedAddress : venueAddress,
                                FoursquareAPIClient.JSONResponseKeys.hours : openHoursData,
                                FoursquareAPIClient.JSONResponseKeys.venueWebsiteAddress : venueWebsiteAddress,
                                FoursquareAPIClient.JSONResponseKeys.bestPhoto : venueCoverPhoto,
                                FoursquareAPIClient.JSONResponseKeys.venueRating : venueRating
                            ]
                            
                            let w2gLocationDetailed = W2GLocationDetailed(dictionary: locationDetails)
                            
                            completionHandler(success: true, locationDetails: w2gLocationDetailed, errorString:nil)
                        }
                        else  if (code - 400) >= 0 && (code - 400) <= 100 {
                            let errorType = JSONResult.valueForKey("meta")!.valueForKey("errorType") as! String
                            let errorDetail = JSONResult.valueForKey("meta")!.valueForKey("errorDetail") as! String
                            let errorMessage = "\(errorType) : \(errorDetail)"
                            
                            completionHandler(success: false, locationDetails: nil, errorString: errorMessage)
                        }
                        else {
                            completionHandler(success: false, locationDetails: nil, errorString: "There was a problem with the response from Foursquare")
                        }
                    }
                    else {
                        print(JSONResult)
                        completionHandler(success: false, locationDetails: nil, errorString: "There was an error getting venue details from Foursquare, the JSON response did not contain a response key")
                    }
                }
            }
        }
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
                    completionHandler(success: false, userDataDictionary: nil, errorString: "There was an error getting nearby locations from Foursquare: \(error?.userInfo)")
                }
                else {
                    if let userDataDict = JSONResult.valueForKey("response")?.valueForKey("groups") as? [[String:AnyObject]] {
                        
                        let code = JSONResult.valueForKey("meta")!.valueForKey("code") as! Int
                        if code == 200 {
                            
                            /*
                            let venueName = venueDict[FoursquareAPIClient.JSONResponseKeys.venueName] as! String
                            let venuePhoneNumber = (venueDict[FoursquareAPIClient.JSONResponseKeys.contact] as! [String:AnyObject])[FoursquareAPIClient.JSONResponseKeys.formattedPhone] as? String ?? "No Phone Number"
                            let venueAddress = (venueDict[FoursquareAPIClient.JSONResponseKeys.location] as! [String:AnyObject])[FoursquareAPIClient.JSONResponseKeys.formattedAddress] as? [String] ?? ["No address information"]
                            
                            let venueWebsiteAddress = venueDict[FoursquareAPIClient.JSONResponseKeys.venueWebsiteAddress] as? String ?? "No Website Address Available"
                            let venueRating = venueDict[FoursquareAPIClient.JSONResponseKeys.venueRating] as? Double ?? 0.0
                            
                            
                            var openHoursData = [String]()
                            
                            if let hours = venueDict[FoursquareAPIClient.JSONResponseKeys.hours] as? [String:AnyObject] {
                            
                            let venueOpeningHours = hours[FoursquareAPIClient.JSONResponseKeys.timeframes] as! [[String:AnyObject]]
                            
                            for timeframe in venueOpeningHours {
                            let days = timeframe["days"] as! String
                            openHoursData.append("\(days):")
                            
                            let openTimesPerDay = timeframe["open"] as! [[String:AnyObject]]
                            for openTime in openTimesPerDay {
                            openHoursData.append(openTime["renderedTime"] as! String)
                            }
                            }
                            
                            } else {
                            openHoursData.append("No Opening Hours Data Available")
                            }
                            
                            var venueCoverPhoto = ""
                            
                            if let bestPhoto = venueDict[FoursquareAPIClient.JSONResponseKeys.bestPhoto] as? [String:AnyObject] {
                            venueCoverPhoto = "\(bestPhoto[FoursquareAPIClient.JSONResponseKeys.bestPhotoPrefix]!)original\(bestPhoto[FoursquareAPIClient.JSONResponseKeys.bestPhotoSuffix]!)"
                            }
                            
                            
                            let locationDetails:[String:AnyObject] = [
                            FoursquareAPIClient.JSONResponseKeys.venueName:venueName,
                            FoursquareAPIClient.JSONResponseKeys.formattedPhone : venuePhoneNumber,
                            FoursquareAPIClient.JSONResponseKeys.formattedAddress : venueAddress,
                            FoursquareAPIClient.JSONResponseKeys.hours : openHoursData,
                            FoursquareAPIClient.JSONResponseKeys.venueWebsiteAddress : venueWebsiteAddress,
                            FoursquareAPIClient.JSONResponseKeys.bestPhoto : venueCoverPhoto,
                            FoursquareAPIClient.JSONResponseKeys.venueRating : venueRating
                            ]
                            
                            let w2gLocationDetailed = W2GLocationDetailed(dictionary: locationDetails)
                            
                            completionHandler(success: true, locationDetails: w2gLocationDetailed, errorString:nil)
                            
                            =================================
                            */
                            
                            
                            
                            
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
                        completionHandler(success: false, userDataDictionary: nil, errorString: "There was an error getting nearby locations from Foursquare, the JSON response did not contain a response key")
                    }
                }
            }
        }
    }

}