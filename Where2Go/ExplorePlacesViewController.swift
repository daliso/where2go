//
//  ExplorePlacesViewController.swift
//  Where2Go
//
//  Created by Daliso Zuze on 03/10/2015.
//  Copyright © 2015 Daliso Zuze. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ExplorePlacesViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    var canGetLocation = false
    var connectionStatus:ReachabilityStatus = Reach().connectionStatus() {
        didSet {
            print("update the UI here to show or hide the notification")
            updateConnectionStatusView()
        }
    }
    var userLocation:CLLocationCoordinate2D!
    var locationManager: CLLocationManager!
    var placesCategory:String = "Food" {
        didSet{
            refreshVenues()
        }
    }
    
    var zoomedIn:MKCoordinateRegion {
        get {
            let regionRadius: CLLocationDistance = 2000
            return MKCoordinateRegionMakeWithDistance(userLocation, regionRadius, regionRadius)
        }
    }
    
    
    @IBAction func categoryControl(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            placesCategory = "Food"
        }
        else if sender.selectedSegmentIndex == 1 {
            placesCategory = "Arts & Entertainment"
        }
    }

    @IBOutlet weak var exploreMapView: MKMapView!
    @IBAction func refreshVenues(sender: UIBarButtonItem) {
        refreshVenues()
        // print (exploreMapView.userLocation.coordinate)
    }

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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("networkStatusChanged:"), name: ReachabilityStatusChangedNotification, object: nil)
        Reach().monitorReachabilityChanges()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        exploreMapView.delegate = self

        refreshVenues()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateConnectionStatusView(){
        switch connectionStatus {
        case .Unknown, .Offline:
            print("Not connected")
        case .Online(.WWAN):
            print("Connected via WWAN")
        case .Online(.WiFi):
            print("Connected via WiFi")
        }
    }
    
//    if editingPins {
//    
//    UIView.animateWithDuration(0.2,
//    delay: 0.0,
//    options: UIViewAnimationOptions.CurveEaseInOut,
//    animations: {self.view.frame.origin.y -= 74},
//    completion:nil)
//    }
//    else {
//    UIView.animateWithDuration(0.3,
//    delay: 0.0,
//    usingSpringWithDamping: CGFloat(2.0),
//    initialSpringVelocity: CGFloat(2.0),
//    options: UIViewAnimationOptions.CurveEaseInOut,
//    animations: {self.view.frame.origin.y += 74},
//    completion:nil)
//    }
    
    func networkStatusChanged(notification: NSNotification) {
        //let userInfo = notification.userInfo
        //print(userInfo)
        connectionStatus = Reach().connectionStatus()
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if (status == .AuthorizedWhenInUse) {
            exploreMapView.showsUserLocation = true
            canGetLocation = true
            print("Authorized to get user location")
            manager.startUpdatingLocation()
        }
        else {
            exploreMapView.showsUserLocation = false
            canGetLocation = false
            print("Not authorized to get user location")
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        print("did update location to: \(newLocation)")
        userLocation = newLocation.coordinate
        exploreMapView.setRegion(zoomedIn, animated: true)
        manager.stopUpdatingLocation()
    }
    
    func refreshVenues(){
        spinner.startAnimating()
        exploreMapView.alpha = CGFloat(0.5)
        let lat = exploreMapView.region.center.latitude
        let lon = exploreMapView.region.center.longitude
        let radius = max(exploreMapView.region.span.latitudeDelta/2.0*110574.61, exploreMapView.region.span.longitudeDelta/2.0*111302.62)
   
        FoursquareAPIClient.sharedInstance.getNearbyLocations(placesCategory, lat:lat, lon:lon, radius: radius) { (success, userDataDict, errorString) -> Void in
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
                    
                    self.exploreMapView.removeAnnotations(self.exploreMapView.annotations)
                    self.exploreMapView.addAnnotations(MKW2GLocation.MKW2GLocationsFromW2GLocations(w2glocations))
                })
                
            } else{
                print("shucks..")
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.spinner.stopAnimating()
                self.exploreMapView.alpha = CGFloat(1.0)
            })
        }
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        refreshVenues()
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("callout tapped: \((view.annotation as! MKW2GLocation).w2gLocation.venueName)")
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

