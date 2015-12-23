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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
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
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("TripCell")
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "TripCell")
            cell!.textLabel?.text = "\((fetchedResultsController.objectAtIndexPath(indexPath) as! Trip).venueName!)"
            cell!.detailTextLabel?.text = "\((fetchedResultsController.objectAtIndexPath(indexPath) as! Trip).dateTime!)"
        } else {
            cell!.textLabel?.text = "\((fetchedResultsController.objectAtIndexPath(indexPath) as! Trip).venueName!)"
            cell!.detailTextLabel?.text = "\((fetchedResultsController.objectAtIndexPath(indexPath) as! Trip).dateTime!)"
        }
        
        return cell!
        
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    
//    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "This is section number:\(section)"
//    }
    
//    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        let height:CGFloat = 40
//        return height
//    }
    
    
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
        case NSFetchedResultsChangeType.Insert : self.myTripsTable.insertRowsAtIndexPaths([NSIndexPath(forRow: newIndexPath!.row, inSection: 3)], withRowAnimation: UITableViewRowAnimation.Automatic)
            break
        case NSFetchedResultsChangeType.Delete : self.myTripsTable.deleteRowsAtIndexPaths([NSIndexPath(forRow: newIndexPath!.row, inSection: 3)], withRowAnimation: UITableViewRowAnimation.Automatic)
            break
        case NSFetchedResultsChangeType.Update : self.myTripsTable.reloadRowsAtIndexPaths([NSIndexPath(forRow: newIndexPath!.row, inSection: 3)], withRowAnimation: UITableViewRowAnimation.Automatic)
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

}
