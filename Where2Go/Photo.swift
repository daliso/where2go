//
//  Photo.swift
//  VirtualTourist
//
//  Created by Daliso Zuze on 26/09/2015.
//  Copyright © 2015 Daliso Zuze. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Photo: NSManagedObject {

    var imageURL:String = ""
    
    init(imageURL:String) {
        self.imageURL = imageURL
    }
    
    var foursquareImage: UIImage? {
        
        get {
            return FoursquareAPIClient.Caches.imageCache.imageWithIdentifier(imageURL)
        }
        
        set {
            FoursquareAPIClient.Caches.imageCache.storeImage(newValue, withIdentifier: imageURL)
        }
    }
    
    deinit {
        foursquareImage = nil
    }

}
