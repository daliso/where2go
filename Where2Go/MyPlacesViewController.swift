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
    lazy var fetchedResultsController: NSFetchedResultsController<Trip> = {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Trip")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateTime", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController as! NSFetchedResultsController<Trip>
        
    }()
    
    // MARK: TableView Deletage Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTrip = (fetchedResultsController.object(at: indexPath) )
        performSegue(withIdentifier: Constants.segueToTripDetailsFromMyTrips, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: Constants.tripCellIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: Constants.tripCellIdentifier)
            cell!.textLabel?.text = "\((fetchedResultsController.object(at: indexPath) ).venueName!)"
            
            let timestamp = DateFormatter.localizedString(from: (fetchedResultsController.object(at: indexPath) ).dateTime!, dateStyle: .full, timeStyle: .short)

            cell!.detailTextLabel?.text = "\(timestamp)"
            
        } else {
            cell!.textLabel?.text = "\((fetchedResultsController.object(at: indexPath) ).venueName!)"
            let timestamp = DateFormatter.localizedString(from: (fetchedResultsController.object(at: indexPath) ).dateTime!, dateStyle: .full, timeStyle: .short)
            
            cell!.detailTextLabel?.text = "\(timestamp)"
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    
    // MARK: FetchedResultsController Delegate Methods
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("Inside controllerWillChangeContent in MyPlaces")
        self.myTripsTable.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("Inside controllerDidChangeContent in MyPlaces")
        self.myTripsTable.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        print("Inside ControllerDidChangeObject in MyPlaces")
        switch(type) {
        case NSFetchedResultsChangeType.insert : self.myTripsTable.insertRows(at: [newIndexPath!], with: UITableViewRowAnimation.automatic)
        case NSFetchedResultsChangeType.delete : self.myTripsTable.deleteRows(at: [indexPath!], with: UITableViewRowAnimation.automatic)
        case NSFetchedResultsChangeType.update :
            self.myTripsTable.reloadRows(at: [indexPath!], with: UITableViewRowAnimation.automatic)
        case NSFetchedResultsChangeType.move:
            self.myTripsTable.deleteRows(at: [indexPath!], with: UITableViewRowAnimation.automatic)
            self.myTripsTable.insertRows(at: [newIndexPath!], with: UITableViewRowAnimation.automatic)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch(type) {
        case NSFetchedResultsChangeType.insert : self.myTripsTable.insertSections(IndexSet(integer: sectionIndex), with: UITableViewRowAnimation.automatic)
            break
        case NSFetchedResultsChangeType.delete : self.myTripsTable.deleteSections(IndexSet(integer: sectionIndex), with: UITableViewRowAnimation.automatic)
            break
        default:
            print("Nothing")
        }
    }

    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! DisplayTripDetailsViewController
        vc.theTrip = selectedTrip
    }
    
    // MARK: Constants
    fileprivate struct Constants {
        static let segueToTripDetailsFromMyTrips = "showTripDetailsFromMyTrips"
        static let tripCellIdentifier = "TripCell"
    }

}
