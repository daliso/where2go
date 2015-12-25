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
    @IBOutlet weak var exploreMapView: MKMapView!
    @IBOutlet weak var zoomToUserButton: UIBarButtonItem!

    // MARK: Vars
    var userLocation:CLLocationCoordinate2D? = nil
    var locationManager: CLLocationManager!
    var selectedLocation:W2GLocation? = nil

    var connectionStatus:ReachabilityStatus = Reach().connectionStatus() {
        didSet {
            updateConnectionStatusView()
        }
    }
    var placesCategory:String = "Food" {
        didSet{
            refreshVenues()
        }
    }
    var zoomedIn:MKCoordinateRegion {
        get {
            let regionRadius: CLLocationDistance = 2000
            return MKCoordinateRegionMakeWithDistance(userLocation!, regionRadius, regionRadius)
        }
    }

    lazy var connectionNoticeContraints1:NSLayoutConstraint = NSLayoutConstraint(item: self.exploreMapView, attribute:
        NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.noConnectionView,
        attribute: NSLayoutAttribute.Bottom, multiplier: 1.0,
        constant: 0)
    
    lazy var connectionNoticeContraints2:NSLayoutConstraint = NSLayoutConstraint(item: self.exploreMapView, attribute:
        NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.noConnectionView,
        attribute: NSLayoutAttribute.Bottom, multiplier: 1.0,
        constant: -47)

    
    @IBAction func categoryControl(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            placesCategory = "Food"
        }
        else if sender.selectedSegmentIndex == 1 {
            placesCategory = "Arts & Entertainment"
        }
    }
    
    // MARK: IBActions
    @IBAction func zoomToUserButtonPressed(sender: UIBarButtonItem) {
        if userLocation != nil {
            exploreMapView.setRegion(zoomedIn, animated: true)
        }
    }

    // MARK: ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("networkStatusChanged:"), name: ReachabilityStatusChangedNotification, object: nil)
        Reach().monitorReachabilityChanges()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        exploreMapView.delegate = self
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        let latitude = defaults.doubleForKey("centerLatitude")
        let longitude = defaults.doubleForKey("centerLongitude")
        let latDelta = defaults.doubleForKey("latDelta")
        let lonDelta = defaults.doubleForKey("lonDelta")
        
        if !(latitude == 0) && !(longitude == 0) && !(latDelta == 0) && !(lonDelta == 0) {
            let mapCenter = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
            let mapSpan = MKCoordinateSpan(latitudeDelta: CLLocationDegrees(latDelta), longitudeDelta: CLLocationDegrees(lonDelta))
            let savedRegion = MKCoordinateRegion(center: mapCenter, span: mapSpan)
            exploreMapView.setRegion(savedRegion, animated: true)
        }
    }
    
    // MARK: Connection Status Methods
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
        connectionStatus = Reach().connectionStatus()
    }
    
    
    // MARK: Location Tracking Methods
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if (status == .AuthorizedWhenInUse) {
            exploreMapView.showsUserLocation = true
            exploreMapView.showsCompass = true
            print("Authorized to get user location")
            zoomToUserButton.enabled = true
            manager.startUpdatingLocation()
        }
        else {
            zoomToUserButton.enabled = false
            exploreMapView.showsUserLocation = false
            print("Not authorized to get user location")
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        print("did update location to: \(newLocation)")
        userLocation = newLocation.coordinate
        // exploreMapView.setRegion(zoomedIn, animated: true)
        manager.stopUpdatingLocation()
    }
    
    // MARK: API call for more venues
    func refreshVenues(){
        spinner.startAnimating()
        exploreMapView.alpha = CGFloat(0.5)
        let lat = exploreMapView.region.center.latitude
        let lon = exploreMapView.region.center.longitude
        
        let width = exploreMapView.region.span.latitudeDelta/2.0*110574.61
        let height = exploreMapView.region.span.longitudeDelta/2.0*111302.62
        let radius = sqrt(pow(width,2.0)+pow(height,2.0))
   
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
                print("No locations returned...")
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.spinner.stopAnimating()
                self.exploreMapView.alpha = CGFloat(1.0)
            })
        }
    }
    
    // MARK: MapView delegate methods
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setDouble(mapView.region.center.latitude, forKey: "centerLatitude")
        defaults.setDouble(mapView.region.center.longitude, forKey: "centerLongitude")
        defaults.setDouble(mapView.region.span.latitudeDelta, forKey: "latDelta")
        defaults.setDouble(mapView.region.span.longitudeDelta, forKey: "lonDelta")
        refreshVenues()
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if (annotation.isEqual(mapView.userLocation)){
            return nil
        }
        
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
    
    // MARK: Mavigation
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        switch connectionStatus {
        case .Unknown, .Offline:
            return false
        case .Online(.WWAN), .Online(.WiFi):
            return true
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! PlacesDetailViewController
        vc.venueID = selectedLocation!.venueID
    }
    
    // MARK: Constants
    private struct Constants {
        static let segueToPlacesDetailViewController = "showPlaceDetailFromExplore"
        static let AnnotationViewReuseIdentifier = "locationPin"
    }
}

