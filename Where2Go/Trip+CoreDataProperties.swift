//
//  Trip+CoreDataProperties.swift
//  Where2Go
//
//  Created by Daliso Zuze on 20/12/2015.
//  Copyright © 2015 Daliso Zuze. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Trip {

    @NSManaged var dateTime: Date?
    @NSManaged var id: NSNumber?
    @NSManaged var notes: String?
    @NSManaged var venueID: String?
    @NSManaged var venueName: String?

}
