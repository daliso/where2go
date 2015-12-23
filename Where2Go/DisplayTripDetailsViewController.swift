//
//  DisplayTripDetailsViewController.swift
//  Where2Go
//
//  Created by Daliso Zuze on 23/12/2015.
//  Copyright © 2015 Daliso Zuze. All rights reserved.
//

import UIKit
import CoreData

class DisplayTripDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var displayTripView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let editTripButton : UIBarButtonItem = UIBarButtonItem(title: "Edit Trip", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("editTripButtonPressed:"))
        self.navigationItem.rightBarButtonItem = editTripButton
        
        displayTripView.delegate = self
        displayTripView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func editTripButtonPressed(sender: AnyObject){
    }
    
    // MARK: Core Data
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance.managedObjectContext
    }
    
    // MARK: FetchedResults Controller and Delegate Methods
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Trip")
        
        //fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateTime", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "id == %@", 1);
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    // MARK: TableView Deletage Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Here we will segue to the Trip details view page
        // performSegueWithIdentifier("showTripDetailsFromMyTrips", sender: self)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        switch indexPath.section {
        case 0:
            var cell = tableView.dequeueReusableCellWithIdentifier("TripLocationCell")
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "TripLocationCell")
                cell!.textLabel?.text = "This is the location name"
            } else {
                cell!.textLabel?.text = "This is the location name"
            }
            return cell!
            
        case 1:
            var cell = tableView.dequeueReusableCellWithIdentifier("TripDateTimeCell")
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "TripLocationCell")
                cell!.textLabel?.text = "This is the date/time"
            } else {
                cell!.textLabel?.text = "This is the date/time"
            }
            return cell!
        case 2:
            var cell = tableView.dequeueReusableCellWithIdentifier("TripNotesCell")
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "TripLocationCell")
                cell!.textLabel?.text = "These are the Trip notes"
            } else {
                cell!.textLabel?.text = "This is the Trip notes"
            }
            return cell!
        default:
            return UITableViewCell()
        }
        
        
        /*
        var cell = tableView.dequeueReusableCellWithIdentifier("TripCell")
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "TripCell")
            cell!.textLabel?.text = "\((fetchedResultsController.objectAtIndexPath(indexPath) as! Trip).venueName!)"
            
            let timestamp = NSDateFormatter.localizedStringFromDate((fetchedResultsController.objectAtIndexPath(indexPath) as! Trip).dateTime!, dateStyle: .FullStyle, timeStyle: .ShortStyle)
            
            cell!.detailTextLabel?.text = "\(timestamp)"
            
            //cell!.detailTextLabel?.text = "\((fetchedResultsController.objectAtIndexPath(indexPath) as! Trip).dateTime!)"
        } else {
            cell!.textLabel?.text = "\((fetchedResultsController.objectAtIndexPath(indexPath) as! Trip).venueName!)"
            let timestamp = NSDateFormatter.localizedStringFromDate((fetchedResultsController.objectAtIndexPath(indexPath) as! Trip).dateTime!, dateStyle: .FullStyle, timeStyle: .ShortStyle)
            
            cell!.detailTextLabel?.text = "\(timestamp)"
        }
        return cell!
        */
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Location Name"
        case 1: return "Time and Date"
        case 2: return "Trip Notes"
        default: return "default section title"
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let height:CGFloat = 50
        return height
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        print("Inside controllerWillChangeContent in MyPlaces")
        self.displayTripView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        print("Inside controllerDidChangeContent in MyPlaces")
        self.displayTripView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        print("Inside ControllerDidChangeObject in MyPlaces")
        switch(type) {
        case NSFetchedResultsChangeType.Insert : self.displayTripView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
            break
        case NSFetchedResultsChangeType.Delete : self.displayTripView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
            break
        case NSFetchedResultsChangeType.Update : self.displayTripView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
        default:
            print("Nothing")
        }
    }
    
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch(type) {
        case NSFetchedResultsChangeType.Insert : self.displayTripView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Automatic)
            break
        case NSFetchedResultsChangeType.Delete : self.displayTripView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Automatic)
            break
        default:
            print("Nothing")
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
