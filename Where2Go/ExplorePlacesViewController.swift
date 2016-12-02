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
    var placesCategory:String = Constants.FoodCategory {
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
        NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.noConnectionView,
        attribute: NSLayoutAttribute.bottom, multiplier: 1.0,
        constant: 0)
    
    lazy var connectionNoticeContraints2:NSLayoutConstraint = NSLayoutConstraint(item: self.exploreMapView, attribute:
        NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.noConnectionView,
        attribute: NSLayoutAttribute.bottom, multiplier: 1.0,
        constant: -47)

    
    @IBAction func categoryControl(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            placesCategory = Constants.FoodCategory
        }
        else if sender.selectedSegmentIndex == 1 {
            placesCategory = Constants.EntertainmentCategory
        }
    }
    
    // MARK: IBActions
    @IBAction func zoomToUserButtonPressed(_ sender: UIBarButtonItem) {
        if userLocation != nil {
            exploreMapView.setRegion(zoomedIn, animated: true)
        }
    }

    // MARK: ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       
        NotificationCenter.default.addObserver(self, selector: #selector(ExplorePlacesViewController.networkStatusChanged(_:)), name: NSNotification.Name(rawValue: ReachabilityStatusChangedNotification), object: nil)
        Reach().monitorReachabilityChanges()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        exploreMapView.delegate = self
        
        let defaults = UserDefaults.standard
        
        let latitude = defaults.double(forKey: Constants.CenterLatitudeKey)
        let longitude = defaults.double(forKey: Constants.CenterLongitudeKey)
        let latDelta = defaults.double(forKey: Constants.LatitudeDeltaKey)
        let lonDelta = defaults.double(forKey: Constants.LongitudeDeltaKey)
        
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
        case .unknown, .offline:
            print("Connection Status: Not connected")
            UIView.animate(withDuration: 0.2,
            delay: 0.0,
            options: UIViewAnimationOptions(),
            animations: {self.noConnectionView.frame.origin.y = 0},
            completion:nil)
            
            view.removeConstraint(connectionNoticeContraints1)
            view.addConstraint(connectionNoticeContraints2)
            
        case .online(.wwan), .online(.wiFi):
            print("Connection Status: Connected via WWAN")
            UIView.animate(withDuration: 0.3,
            delay: 0.0,
            usingSpringWithDamping: CGFloat(2.0),
            initialSpringVelocity: CGFloat(2.0),
            options: UIViewAnimationOptions(),
            animations: {self.noConnectionView.frame.origin.y = -47},
            completion:nil)
            
            view.removeConstraint(connectionNoticeContraints2)
            view.addConstraint(connectionNoticeContraints1)
        }
    }
    
    func networkStatusChanged(_ notification: Notification) {
        connectionStatus = Reach().connectionStatus()
    }
    
    
    // MARK: Location Tracking Methods
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .authorizedWhenInUse) {
            exploreMapView.showsUserLocation = true
            exploreMapView.showsCompass = true
            print("Authorized to get user location")
            zoomToUserButton.isEnabled = true
            manager.startUpdatingLocation()
        }
        else {
            zoomToUserButton.isEnabled = false
            exploreMapView.showsUserLocation = false
            print("Not authorized to get user location")
        }
    }
    
//    func locationManager(_ manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
//        print("did update location to: \(newLocation)")
//        userLocation = newLocation.coordinate
//        // exploreMapView.setRegion(zoomedIn, animated: true)
//        manager.stopUpdatingLocation()
//    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations[locations.count - 1]
        print("did update location to: \(newLocation)")
        userLocation = newLocation.coordinate
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
   
        FoursquareAPIClient.sharedInstance.getNearbyLocations(placesCategory, lat:lat, lon:lon, radius: radius) { (success, locations, errorString) -> Void in
            if success {
                DispatchQueue.main.async(execute: {
                    self.exploreMapView.removeAnnotations(self.exploreMapView.annotations)
                    self.exploreMapView.addAnnotations(MKW2GLocation.MKW2GLocationsFromW2GLocations(locations!))
                })
                
            } else{
                print("No locations returned...")
            }
            
            DispatchQueue.main.async(execute: {
                self.spinner.stopAnimating()
                self.exploreMapView.alpha = CGFloat(1.0)
            })
        }
    }
    
    // MARK: MapView delegate methods
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let defaults = UserDefaults.standard
        defaults.set(mapView.region.center.latitude, forKey: Constants.CenterLatitudeKey)
        defaults.set(mapView.region.center.longitude, forKey: Constants.CenterLongitudeKey)
        defaults.set(mapView.region.span.latitudeDelta, forKey: Constants.LatitudeDeltaKey)
        defaults.set(mapView.region.span.longitudeDelta, forKey: Constants.LongitudeDeltaKey)
        refreshVenues()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if (annotation.isEqual(mapView.userLocation)){
            return nil
        }
        
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: Constants.AnnotationViewReuseIdentifier)
        
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.AnnotationViewReuseIdentifier)
            view!.canShowCallout = true
        } else {
            view!.annotation = annotation
        }
        
        view!.leftCalloutAccessoryView = nil
        view!.rightCalloutAccessoryView = UIButton(type: UIButtonType.detailDisclosure)
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        selectedLocation = (view.annotation! as! MKW2GLocation).w2gLocation
        performSegue(withIdentifier: Constants.segueToPlacesDetailViewController, sender: nil)
    }
    
    // MARK: Mavigation
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch connectionStatus {
        case .unknown, .offline:
            return false
        case .online(.wwan), .online(.wiFi):
            return true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! PlacesDetailViewController
        vc.venueID = selectedLocation!.venueID
    }
    
    // MARK: Constants
    fileprivate struct Constants {
        static let segueToPlacesDetailViewController = "showPlaceDetailFromExplore"
        static let AnnotationViewReuseIdentifier = "locationPin"
        static let FoodCategory = "Food"
        static let EntertainmentCategory = "Arts & Entertainment"
        static let CenterLatitudeKey = "centerLatitude"
        static let CenterLongitudeKey = "centerLongitude"
        static let LatitudeDeltaKey = "latDelta"
        static let LongitudeDeltaKey = "lonDelta"
    }
}

