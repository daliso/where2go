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
    
    func getVenueDetails(_ venueID: String, completionHandler: @escaping (_ success: Bool, _ locationDetails:W2GLocationDetailed?, _ errorString: String?) -> Void){
        
        switch Reach().connectionStatus() {
        case .offline , .unknown:
            completionHandler(false, nil, "Error: No network connection")
        case .online(.wwan), .online(.wiFi):
            print("getting details for a particular venue")
            let methodArguments = [
                ParameterKeys.FoursquareClientID: Constants.FoursquareClientID,
                ParameterKeys.FoursquareClientSecret: Constants.FoursquareSecret,
                ParameterKeys.FoursquareAPIVersion: Constants.FoursquareAPIVersion,
            ]
            
            _ = taskForGETMethod(venueID, parameters: methodArguments as NSDictionary?, baseUrl: Constants.BaseURLSecure, dataOffSet: 0, headers: nil) { JSONResult, error in
                
                if let _ = error {
                    completionHandler(false, nil, "There was an error getting the location details from Foursquare: \(error?.userInfo)")
                }
                else {
                    if let venueDict = (JSONResult?.value(forKey: "response") as! NSDictionary).value(forKey: "venue") as? [String:AnyObject] {
                        
                        let code = (JSONResult?.value(forKey: "meta")! as! NSDictionary).value(forKey: "code") as! Int
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
                                FoursquareAPIClient.JSONResponseKeys.venueName:venueName as AnyObject,
                                FoursquareAPIClient.JSONResponseKeys.formattedPhone : venuePhoneNumber as AnyObject,
                                FoursquareAPIClient.JSONResponseKeys.formattedAddress : venueAddress as AnyObject,
                                FoursquareAPIClient.JSONResponseKeys.hours : openHoursData as AnyObject,
                                FoursquareAPIClient.JSONResponseKeys.venueWebsiteAddress : venueWebsiteAddress as AnyObject,
                                FoursquareAPIClient.JSONResponseKeys.bestPhoto : venueCoverPhoto as AnyObject,
                                FoursquareAPIClient.JSONResponseKeys.venueRating : venueRating as AnyObject
                            ]
                            
                            let w2gLocationDetailed = W2GLocationDetailed(dictionary: locationDetails)
                            
                            completionHandler(true, w2gLocationDetailed, nil)
                        }
                        else  if (code - 400) >= 0 && (code - 400) <= 100 {
                            let errorType = (JSONResult?.value(forKey: "meta")! as AnyObject).value(forKey: "errorType") as! String
                            let errorDetail = (JSONResult?.value(forKey: "meta")! as AnyObject).value(forKey: "errorDetail") as! String
                            let errorMessage = "\(errorType) : \(errorDetail)"
                            
                            completionHandler(false, nil, errorMessage)
                        }
                        else {
                            completionHandler(false, nil, "There was a problem with the response from Foursquare")
                        }
                    }
                    else {
                        print(JSONResult)
                        completionHandler(false, nil, "There was an error getting venue details from Foursquare, the JSON response did not contain a response key")
                    }
                }
            }
        }
    }
    
    
    func getNearbyLocations(_ section:String, lat:Double, lon:Double, radius:Double, completionHandler: @escaping (_ success: Bool, _ locations: [W2GLocation]?, _ errorString: String?) -> Void) -> Void {
        
        switch Reach().connectionStatus() {
        case .offline , .unknown:
            completionHandler(false, nil, "Error: No network connection")
        case .online(.wwan), .online(.wiFi):
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
            ] as [String : Any]
            
            _ = taskForGETMethod(Methods.Explore, parameters: methodArguments as NSDictionary?, baseUrl: Constants.BaseURLSecure, dataOffSet: 0, headers: nil) { JSONResult, error in
                
                if let _ = error {
                    completionHandler(false, nil, "There was an error getting nearby locations from Foursquare: \(error?.userInfo)")
                }
                else {
                    
                if let userDataDict = (JSONResult?.value(forKey: "response") as! NSDictionary).value(forKey: "groups") as? [[String:AnyObject]] {
                    
                        let code = (JSONResult?.value(forKey: "meta") as! NSDictionary).value(forKey: "code") as! Int
                    
                        if code == 200 {

                            let items = userDataDict.first!["items"] as! [[String:AnyObject]]
                            
                            let w2glocations = items.map { (item) -> W2GLocation in
                            
                                let venue = item["venue"] as! [String:AnyObject]
                                let venueID = venue["id"] as! String
                                let venueName = venue["name"] as! String
                                let venueLocation = venue["location"] as! [String:AnyObject]
                                let venueLat = venueLocation["lat"] as! Double
                                let venueLon = venueLocation["lng"] as! Double
                                
                                let locationDict:[String:AnyObject] = [
                                FoursquareAPIClient.JSONResponseKeys.venueID : venueID as AnyObject,
                                FoursquareAPIClient.JSONResponseKeys.venueName : venueName as AnyObject,
                                FoursquareAPIClient.JSONResponseKeys.Latitude : venueLat as AnyObject,
                                FoursquareAPIClient.JSONResponseKeys.Longitude : venueLon as AnyObject
                                ]
                                return W2GLocation(dictionary: locationDict)
                            }
                            

                            
                            completionHandler(true, w2glocations, nil)
                        }
                        else  if (code - 400) >= 0 && (code - 400) <= 100 {
                            let errorType = (JSONResult?.value(forKey: "meta")! as AnyObject).value(forKey: "errorType") as! String
                            let errorDetail = (JSONResult?.value(forKey: "meta")! as AnyObject).value(forKey: "errorDetail") as! String
                            let errorMessage = "\(errorType) : \(errorDetail)"
                            
                            completionHandler(false, nil, errorMessage)
                        }
                        else {
                            completionHandler(false, nil, "There was a problem with the response from Foursquare")
                        }
                    }
                    else {
                        // need to check here if the JSON result contains some known property with an error message
                        completionHandler(false, nil, "There was an error getting nearby locations from Foursquare, the JSON response did not contain a response key")
                    }
                }
            }
        }
    }

}
