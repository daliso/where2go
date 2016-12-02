//
//  PlacesDetailViewController.swift
//  Where2Go
//
//  Created by Daliso Zuze on 10/10/2015.
//  Copyright © 2015 Daliso Zuze. All rights reserved.
//

import UIKit
import CoreData

class PlacesDetailViewController: UIViewController,  UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {

    // MARK: IBOutlets
    @IBOutlet weak var placeDetailTable: UITableView!
    @IBOutlet weak var venueNameLabel: UILabel!
    @IBOutlet weak var coverPhotoImageView: URLImageView!
    @IBOutlet weak var spinnerView: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    // MARK: Vars
    var tableData:[[String]]? = nil
    var venueID:String = ""
    var locationDetails:W2GLocationDetailed? = nil
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!
    var theTrip:Trip?
    
    // MARK: ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        placeDetailTable.delegate = self
        placeDetailTable.dataSource = self
        
        FoursquareAPIClient.sharedInstance.getVenueDetails(venueID) { (success, locationDetails, errorString) -> Void in
            if success {
                DispatchQueue.main.async(execute: {
                    self.refreshUI(locationDetails!)
                })
            }
            else {
                print("An error occured: \(errorString!)")
            }
        }
        
        let addTripButton : UIBarButtonItem = UIBarButtonItem(title: "Add Trip", style: UIBarButtonItemStyle.plain, target: self, action: #selector(PlacesDetailViewController.addTripButtonPressed(_:)))
        self.navigationItem.rightBarButtonItem = addTripButton
    }
    
    // MARK: UI Event Handlers
    func addTripButtonPressed(_ sender: AnyObject){
        performSegue(withIdentifier: "addTripDetailFromPlacesDetail", sender: self)
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TripDetailsViewController {
            vc.parent2 = self
        } else if let vc = segue.destination as? DisplayTripDetailsViewController {
            vc.theTrip = self.theTrip
        }
    }
    
    // MARK: Refresh State
    func refreshUI(_ locationDetails:W2GLocationDetailed){
        
        startSpinning()
        
        var error: NSError?
        do { try fetchedResultsController.performFetch()}
        catch let error1 as NSError { error = error1 }
        
        if let error = error { print("Error performing fetch: \(error)") }
        
        fetchedResultsController.delegate = self
        
        venueNameLabel.text = locationDetails.name
        self.locationDetails = locationDetails

        coverPhotoImageView.imageURL = locationDetails.coverPhoto!
        
        tableData = [[String]]()
        tableData!.insert(["\(locationDetails.rating!) / 10"], at: 0)
        tableData!.insert(["Tel: \(locationDetails.phoneNumber!)"], at: 1)
        for addressLine in locationDetails.address! {
            tableData![1].append(addressLine)
        }
        tableData![1].append(locationDetails.websiteAddress!)
        tableData!.insert(locationDetails.openingHours!, at: 2)
        
        placeDetailTable.reloadData()
        
        stopSpinning()
    }

    // MARK: TableView Delegate Methods
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if (indexPath as NSIndexPath).section < 3 {
            cell.textLabel?.text = tableData?[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row] ?? ""
        }
        else if (indexPath as NSIndexPath).section == 3 {
            let timestamp = DateFormatter.localizedString(from: (fetchedResultsController.object(at: IndexPath(row: (indexPath as NSIndexPath).row, section: 0)) ).dateTime!, dateStyle: .full, timeStyle: .short)
            cell.textLabel?.text = "\(timestamp)"
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 1
        case 1: return tableData?[1].count ?? 0
        case 2: return tableData?[2].count ?? 0
        case 3: return fetchedResultsController.sections?[0].numberOfObjects ?? 0
        default: return 0
        }
       
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Rating"
        case 1: return "Contact Details"
        case 2: return "Opening Hours"
        case 3: return "Your Planned Trips"
        default: return "section"
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let height:CGFloat = 40
        return height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if ((indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 0){
            print("The cell with the phone number has been tapped")
            
            let textInCell = tableData?[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row] ?? ""
            let textInCellNospaces = textInCell.replacingOccurrences(of: " ", with: "")
            let textInCellNospacesTrimmed = textInCellNospaces.substring(from: textInCellNospaces.characters.index(textInCellNospaces.startIndex, offsetBy: min(textInCellNospaces.characters.count,4)))
            
            if isValidPhoneNumber(textInCellNospacesTrimmed) {
                if let theURL = URL(string: "tel://\(textInCellNospacesTrimmed)") {
                    UIApplication.shared.openURL(theURL)
                }
            }
            
        } else if ((indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == tableData![1].count-1) {
            
            let textInCell = tableData?[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row] ?? ""
            let textInCellNospaces = textInCell.replacingOccurrences(of: " ", with: "")
            
            if isValidURL(textInCellNospaces) {
                if let theURL = URL(string:textInCellNospaces) {
                    UIApplication.shared.openURL(theURL)
                }
            }
        } else if ((indexPath as NSIndexPath).section == 3) {
            
            theTrip = (fetchedResultsController.object(at: IndexPath(row: (indexPath as NSIndexPath).row, section: 0)) )
            performSegue(withIdentifier: Constants.segueToTripDetailsFromPlacesDetail, sender: self)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: Helper Methods
    func isValidURL(_ theURL: String) -> Bool {
        return containsMatch("^(https?:\\/\\/)([\\da-z\\.-]+)\\.([a-z\\.]{2,6})([\\/\\w\\.-]*)*\\/?$", inString: theURL)
    }
    
    func isValidPhoneNumber(_ theURL: String) -> Bool {
        return containsMatch("^\\+?[0-9]{10,}$", inString: theURL)
    }
    
    func containsMatch(_ pattern: String, inString string: String) -> Bool {
        
        var regex = NSRegularExpression()
        
        do {
            regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
        }
        catch {}
        
        let range = NSMakeRange(0, string.characters.count)
        return regex.firstMatch(in: string, options: NSRegularExpression.MatchingOptions(rawValue: UInt(0)), range: range) != nil
    }
    
    
    // MARK: Core Data
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance.managedObjectContext
    }
    
    // MARK: FetchedResults Controller
    lazy var fetchedResultsController: NSFetchedResultsController<Trip> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Trip")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateTime", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "venueID == %@", self.venueID);
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController as! NSFetchedResultsController<Trip>
        
    }()
    
    // MARK: Spinner ON/OFF
    func startSpinning(){
        spinner.startAnimating()
        spinnerView.isHidden = false
    }
    
    func stopSpinning(){
        spinnerView.isHidden = true
        spinner.stopAnimating()
    }
    
    
    // MARK: FetchedResultsController delegate methods
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("Inside controllerWillChangeContent")
        self.placeDetailTable.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("Inside controllerDidChangeContent")
        self.placeDetailTable.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        print("Inside ControllerDidChangeObject")
        switch(type) {
        case NSFetchedResultsChangeType.insert : self.placeDetailTable.insertRows(at: [IndexPath(row: (newIndexPath! as NSIndexPath).row, section: 3)], with: UITableViewRowAnimation.automatic)
        case NSFetchedResultsChangeType.delete : self.placeDetailTable.deleteRows(at: [IndexPath(row: (indexPath! as NSIndexPath).row, section: 3)], with: UITableViewRowAnimation.automatic)
        case NSFetchedResultsChangeType.update :
            self.placeDetailTable.reloadRows(at: [IndexPath(row: (indexPath! as NSIndexPath).row, section: 3)], with: UITableViewRowAnimation.automatic)
        case NSFetchedResultsChangeType.move:
            self.placeDetailTable.deleteRows(at: [IndexPath(row: (indexPath! as NSIndexPath).row, section: 3)], with: UITableViewRowAnimation.automatic)
            self.placeDetailTable.insertRows(at: [IndexPath(row: (newIndexPath! as NSIndexPath).row, section: 3)], with: UITableViewRowAnimation.automatic)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch(type) {
        case NSFetchedResultsChangeType.insert : self.placeDetailTable.insertSections(IndexSet(integer: sectionIndex), with: UITableViewRowAnimation.automatic)
            break
        case NSFetchedResultsChangeType.delete : self.placeDetailTable.deleteSections(IndexSet(integer: sectionIndex), with: UITableViewRowAnimation.automatic)
            break
        default:
            print("Nothing")
        }
    }
    
    // MARK: Constants
    fileprivate struct Constants {
        static let segueToTripDetailsFromPlacesDetail = "showTripDetailsFromPlacesDetail"
    }

}
