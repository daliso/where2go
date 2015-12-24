//
//  MyPlacesViewController.swift
//  Where2Go
//
//  Created by Daliso Zuze on 10/10/2015.
//  Copyright © 2015 Daliso Zuze. All rights reserved.
//

import UIKit
import CoreData

class MyPlacesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate  {

    @IBOutlet weak var myTripsTable: UITableView!
    var selectedTrip:Trip?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        myTripsTable.delegate = self
        myTripsTable.dataSource = self
        
        // Start the fetched results controller
        var error: NSError?
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error = error1
        }
        
        if let error = error {
            print("Error performing initial fetch: \(error)")
        }
        
        fetchedResultsController.delegate = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Core Data
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance.managedObjectContext
    }
    
    // MARK: FetchedResults Controller and Delegate Methods
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Trip")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateTime", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    // MARK: TableView Deletage Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Here we will segue to the Trip details view page
        selectedTrip = (fetchedResultsController.objectAtIndexPath(indexPath) as! Trip)
        performSegueWithIdentifier("showTripDetailsFromMyTrips", sender: self)

        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("TripCell")
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "TripCell")
            cell!.textLabel?.text = "\((fetchedResultsController.objectAtIndexPath(indexPath) as! Trip).venueName!)"
            
            let timestamp = NSDateFormatter.localizedStringFromDate((fetchedResultsController.objectAtIndexPath(indexPath) as! Trip).dateTime!, dateStyle: .FullStyle, timeStyle: .ShortStyle)

            cell!.detailTextLabel?.text = "\(timestamp)"
            
        } else {
            cell!.textLabel?.text = "\((fetchedResultsController.objectAtIndexPath(indexPath) as! Trip).venueName!)"
            let timestamp = NSDateFormatter.localizedStringFromDate((fetchedResultsController.objectAtIndexPath(indexPath) as! Trip).dateTime!, dateStyle: .FullStyle, timeStyle: .ShortStyle)
            
            cell!.detailTextLabel?.text = "\(timestamp)"
        }
        return cell!
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        print("Inside controllerWillChangeContent in MyPlaces")
        self.myTripsTable.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        print("Inside controllerDidChangeContent in MyPlaces")
        self.myTripsTable.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        print("Inside ControllerDidChangeObject in MyPlaces")
        switch(type) {
        case NSFetchedResultsChangeType.Insert : self.myTripsTable.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
            break
        case NSFetchedResultsChangeType.Delete : self.myTripsTable.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
            break
        case NSFetchedResultsChangeType.Update : self.myTripsTable.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
        default:
            print("Nothing")
        }
    }
    
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch(type) {
        case NSFetchedResultsChangeType.Insert : self.myTripsTable.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Automatic)
            break
        case NSFetchedResultsChangeType.Delete : self.myTripsTable.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Automatic)
            break
        default:
            print("Nothing")
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! DisplayTripDetailsViewController
        vc.theTrip = selectedTrip
    }

}
