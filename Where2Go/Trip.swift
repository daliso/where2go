//
//  Trip.swift
//  Where2Go
//
//  Created by Daliso Zuze on 20/12/2015.
//  Copyright © 2015 Daliso Zuze. All rights reserved.
//

import Foundation
import CoreData


class Trip: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    
    struct Keys {
        static let dateTime = "dateTime"
        static let notes = "notes"
        static let venueID = "venueID"
        static let venueName = "venueName"
    }

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Trip", inManagedObjectContext: context)!
        
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        dateTime = dictionary[Keys.dateTime] as? NSDate
        notes = dictionary[Keys.notes] as? String
        venueID = dictionary[Keys.venueID] as? String
        venueName = dictionary[Keys.venueName] as? String

    }

}
