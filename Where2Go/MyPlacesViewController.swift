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

    // MARK: Vars
    var selectedTrip:Trip?
    
    // MARK: IBOutlets
    @IBOutlet weak var myTripsTable: UITableView!
        
    
    // MARK: ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        myTripsTable.delegate = self
        myTripsTable.dataSource = self
        
        // Perform Fetch on the Fetched Results Controller
        var error: NSError?
        do { try fetchedResultsController.performFetch() }
        catch let error1 as NSError { error = error1 }
        
        if let error = error { print("Error performing initial fetch: \(error)") }
        
        fetchedResultsController.delegate = self
    }
    
    // MARK: Core Data
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance.managedObjectContext
    }
    
    // MARK: FetchedResults Controller
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
    
    
    // MARK: FetchedResultsController Delegate Methods
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
        case NSFetchedResultsChangeType.Delete : self.myTripsTable.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
        case NSFetchedResultsChangeType.Update :
            self.myTripsTable.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
        case NSFetchedResultsChangeType.Move:
            self.myTripsTable.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
            self.myTripsTable.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
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

    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! DisplayTripDetailsViewController
        vc.theTrip = selectedTrip
    }

}
