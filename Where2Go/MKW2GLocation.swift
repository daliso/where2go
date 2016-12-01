//
//  MKW2GLocation.swift
//  Where2Go
//
//  Created by Daliso Zuze on 28/11/2015.
//  Copyright (c) 2015 Daliso Zuze. All rights reserved.
//

import UIKit
import MapKit

class MKW2GLocation: NSObject, MKAnnotation
{
    // MARK: - MKAnnotation
    var w2gLocation: W2GLocation
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: Double(w2gLocation.latitude), longitude: Double(w2gLocation.longitude))
    }
    
    var title: String? { return w2gLocation.venueName }
    
    var subtitle: String? { return nil }
    
    init(w2gLocation: W2GLocation) {
        self.w2gLocation = w2gLocation
    }
    
    class func MKW2GLocationsFromW2GLocations(_ w2gLocations: [W2GLocation]) -> [MKW2GLocation] {
        var mkw2gLocations = [MKW2GLocation]()
        for w2gLocation in w2gLocations {
            mkw2gLocations.append(MKW2GLocation(w2gLocation: w2gLocation))
        }
        return mkw2gLocations
    }
    
}
