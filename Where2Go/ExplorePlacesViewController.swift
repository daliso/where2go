//
//  ExplorePlacesViewController.swift
//  Where2Go
//
//  Created by Daliso Zuze on 03/10/2015.
//  Copyright © 2015 Daliso Zuze. All rights reserved.
//

import UIKit
import MapKit

class ExplorePlacesViewController: UIViewController {
    
    @IBOutlet weak var exploreMapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        /*
        let demoLocations = MKW2GLocation.MKW2GLocationsFromW2GLocations(
            W2GLocation.W2GLocationsFromResults(
                createTestAPIResults()
            )
        )

        exploreMapView.addAnnotations(demoLocations)
        */
        
        
        FoursquareAPIClient.sharedInstance.getNearbyLocations("Food", lat: 51.5, lon: -0.22, radius: 2000) { (success, userDataDict, errorString) -> Void in
            if success {
                
                dispatch_async(dispatch_get_main_queue(), {
                    let items = userDataDict!["items"] as! [[String:AnyObject]]
                    
                    let w2glocations = items.map {
                        (let item) -> W2GLocation in
                        
                        let venue = item["venue"] as! [String:AnyObject]
                        let venueID = venue["id"] as! String
                        let venueName = venue["name"] as! String
                        let venueLocation = venue["location"] as! [String:AnyObject]
                        let venueLat = venueLocation["lat"] as! Double
                        let venueLon = venueLocation["lng"] as! Double
                        
                        let locationDict:[String:AnyObject] = [
                            FoursquareAPIClient.JSONResponseKeys.venueID : venueID,
                            FoursquareAPIClient.JSONResponseKeys.venueName : venueName,
                            FoursquareAPIClient.JSONResponseKeys.Latitude : venueLat,
                            FoursquareAPIClient.JSONResponseKeys.Longitude : venueLon
                        ]
                        return W2GLocation(dictionary: locationDict)
                    }
                    self.exploreMapView.addAnnotations(MKW2GLocation.MKW2GLocationsFromW2GLocations(w2glocations))
                })
                
            } else{
                print("shucks...")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func createTestAPIResults() -> [[String: AnyObject]] {
        
        var testResults = [[String: AnyObject]]()
        
        testResults.append(
            [
                FoursquareAPIClient.JSONResponseKeys.venueID : "4b23b0a5f964a520175824e3",
                FoursquareAPIClient.JSONResponseKeys.venueName : "YO! Sushi",
                FoursquareAPIClient.JSONResponseKeys.Latitude : 51.50692612,
                FoursquareAPIClient.JSONResponseKeys.Longitude : -0.22103548
            ]
        )
        
        testResults.append(
            [
                FoursquareAPIClient.JSONResponseKeys.venueID : "5172f248e4b09adb685ea45f",
                FoursquareAPIClient.JSONResponseKeys.venueName : "Mr Sushi",
                FoursquareAPIClient.JSONResponseKeys.Latitude : 51.50312037114186,
                FoursquareAPIClient.JSONResponseKeys.Longitude : -0.2237503036553875
            ]
        )
        
        testResults.append(
            [
                FoursquareAPIClient.JSONResponseKeys.venueID : "55412714498eba342dfd063f",
                FoursquareAPIClient.JSONResponseKeys.venueName : "Sticks N Sushi",
                FoursquareAPIClient.JSONResponseKeys.Latitude : 51.50603657743944,
                FoursquareAPIClient.JSONResponseKeys.Longitude : -0.018242708075009856
            ]
        )
        
        return testResults
    }


}

