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
    
    // MARK: Outlets
    @IBOutlet weak var noConnectionView: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var canGetLocation = false
    var connectionStatus:ReachabilityStatus = Reach().connectionStatus() {
        didSet {
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
    var selectedLocation:W2GLocation? = nil

    lazy var connectionNoticeContraints1:NSLayoutConstraint = NSLayoutConstraint(item: self.exploreMapView, attribute:
        NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.noConnectionView,
        attribute: NSLayoutAttribute.Bottom, multiplier: 1.0,
        constant: 0)
    
    lazy var connectionNoticeContraints2:NSLayoutConstraint = NSLayoutConstraint(item: self.exploreMapView, attribute:
        NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.noConnectionView,
        attribute: NSLayoutAttribute.Bottom, multiplier: 1.0,
        constant: -47)
    
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
       
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("networkStatusChanged:"), name: ReachabilityStatusChangedNotification, object: nil)
        Reach().monitorReachabilityChanges()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        exploreMapView.delegate = self

        refreshVenues()
    }
    
    override func viewDidAppear(animated: Bool) {
        print("view did appear called")
    }
    
    override func viewWillAppear(animated: Bool) {
        print("view will appear called")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateConnectionStatusView(){
        switch connectionStatus {
        case .Unknown, .Offline:
            print("Connection Status: Not connected")
            UIView.animateWithDuration(0.2,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: {self.noConnectionView.frame.origin.y = 0},
            completion:nil)
            
            view.removeConstraint(connectionNoticeContraints1)
            view.addConstraint(connectionNoticeContraints2)
            
        case .Online(.WWAN), .Online(.WiFi):
            print("Connection Status: Connected via WWAN")
            UIView.animateWithDuration(0.3,
            delay: 0.0,
            usingSpringWithDamping: CGFloat(2.0),
            initialSpringVelocity: CGFloat(2.0),
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: {self.noConnectionView.frame.origin.y = -47},
            completion:nil)
            
            
            view.removeConstraint(connectionNoticeContraints2)
            view.addConstraint(connectionNoticeContraints1)
        }
    }

    
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
    
//    
//    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
//        selectedLocation = (view.annotation! as! W2GLocation)
//        performSegueWithIdentifier(Constants.segueToPlacesDetailViewController, sender: nil)
//    }
//    
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier(Constants.AnnotationViewReuseIdentifier)
        
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.AnnotationViewReuseIdentifier)
            view!.canShowCallout = true
        } else {
            view!.annotation = annotation
        }
        
        view!.leftCalloutAccessoryView = nil
        view!.rightCalloutAccessoryView = UIButton(type: UIButtonType.DetailDisclosure)
        return view
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        selectedLocation = (view.annotation! as! MKW2GLocation).w2gLocation
        performSegueWithIdentifier(Constants.segueToPlacesDetailViewController, sender: nil)
    }
    
        
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! PlacesDetailViewController
        vc.venueID = selectedLocation!.venueID
    }
    
    private struct Constants {
        static let segueToPlacesDetailViewController = "showPlaceDetailFromExplore"
        static let AnnotationViewReuseIdentifier = "locationPin"
    }
}

