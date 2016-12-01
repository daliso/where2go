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

    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entity(forEntityName: "Trip", in: context)!
        
        super.init(entity: entity,insertInto: context)
        
        dateTime = dictionary[Keys.dateTime] as? Date
        notes = dictionary[Keys.notes] as? String
        venueID = dictionary[Keys.venueID] as? String
        venueName = dictionary[Keys.venueName] as? String

    }

}
