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

    @IBOutlet weak var placeDetailTable: UITableView!
    @IBOutlet weak var venueNameLabel: UILabel!
    @IBOutlet weak var coverPhotoImageView: URLImageView!
    @IBOutlet weak var spinnerView: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var tableData:[[String]]? = nil
    
    var venueID:String = "49ecf7f1f964a520ba671fe3"
    var locationDetails:W2GLocationDetailed? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        placeDetailTable.delegate = self
        placeDetailTable.dataSource = self
        
        FoursquareAPIClient.sharedInstance.getVenueDetails(venueID) { (success, locationDetails, errorString) -> Void in
            if success {
                // refreshUI using the locationdetails
                dispatch_async(dispatch_get_main_queue(), {
                    self.refreshUI(locationDetails!)
                })
            }
            else {
                // display an error
                print("An error occured: \(errorString!)")
            }
        }
        
        let addTripButton : UIBarButtonItem = UIBarButtonItem(title: "Add Trip", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("addTripButtonPressed:"))
        self.navigationItem.rightBarButtonItem = addTripButton
        
    }
    
    func addTripButtonPressed(sender: AnyObject){
        performSegueWithIdentifier("showTripDetailFromPlacesDetail", sender: self)
    }
    
    func refreshUI(locationDetails:W2GLocationDetailed){
        
        startSpinning()
        
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
        
        
        venueNameLabel.text = locationDetails.name
        self.locationDetails = locationDetails

        coverPhotoImageView.imageURL = locationDetails.coverPhoto!
        
        tableData = [[String]]()
        tableData!.insert(["\(locationDetails.rating!) / 10"], atIndex: 0)
        tableData!.insert(["Tel: \(locationDetails.phoneNumber!)"], atIndex: 1)
        for addressLine in locationDetails.address! {
            tableData![1].append(addressLine)
        }
        tableData![1].append(locationDetails.websiteAddress!)
        
        tableData!.insert(locationDetails.openingHours!, atIndex: 2)
        
        // tableData!.insert(, atIndex: 3)
    
        placeDetailTable.reloadData()
        
        stopSpinning()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        
        if indexPath.section < 3 {
            cell.textLabel?.text = tableData?[indexPath.section][indexPath.row] ?? ""
        }
        else if indexPath.section == 3 {
            cell.textLabel?.text = "\(fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: indexPath.row, inSection: 0)) as! Trip).dateTime)"
            // cell.textLabel?.text = "I am cell: \(indexPath.section) , \(indexPath.row)"
        }
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 1
        case 1: return tableData?[1].count ?? 0
        case 2: return tableData?[2].count ?? 0
        case 3: return fetchedResultsController.sections?[0].numberOfObjects ?? 0
        default: return 0
        }
       
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Rating"
        case 1: return "Contact Details"
        case 2: return "Opening Hours"
        case 3: return "Your Planned Trips"
        default: return "section"
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let height:CGFloat = 40
        return height
    }
    
    func isValidURL(theURL: String) -> Bool {
        return containsMatch("^(https?:\\/\\/)([\\da-z\\.-]+)\\.([a-z\\.]{2,6})([\\/\\w\\.-]*)*\\/?$", inString: theURL)
    }
    
    func isValidPhoneNumber(theURL: String) -> Bool {
        return containsMatch("^\\+?[0-9]{10,}$", inString: theURL)
    }
    
    func containsMatch(pattern: String, inString string: String) -> Bool {
        
        var regex = NSRegularExpression()
        
        do {
            regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.CaseInsensitive)
        }
        catch {}
        
        let range = NSMakeRange(0, string.characters.count)
        return regex.firstMatchInString(string, options: NSMatchingOptions(rawValue: UInt(0)), range: range) != nil
    }
    
    
    // MARK: TableView Deletage Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if (indexPath.section == 1 && indexPath.row == 0){
            print("The cell with the phone number has been tapped")
            
            let textInCell = tableData?[indexPath.section][indexPath.row] ?? ""
            let textInCellNospaces = textInCell.stringByReplacingOccurrencesOfString(" ", withString: "")
            let textInCellNospacesTrimmed = textInCellNospaces.substringFromIndex(textInCellNospaces.startIndex.advancedBy(min(textInCellNospaces.characters.count,4)))
            
            if isValidPhoneNumber(textInCellNospacesTrimmed) {
                if let theURL = NSURL(string: "tel://\(textInCellNospacesTrimmed)") {
                    UIApplication.sharedApplication().openURL(theURL)
                }
            }
            
        } else if (indexPath.section == 1 && indexPath.row == tableData![1].count-1) {
            
            let textInCell = tableData?[indexPath.section][indexPath.row] ?? ""
            let textInCellNospaces = textInCell.stringByReplacingOccurrencesOfString(" ", withString: "")
            
            if isValidURL(textInCellNospaces) {
                if let theURL = NSURL(string:textInCellNospaces) {
                    UIApplication.sharedApplication().openURL(theURL)
                }
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: Core Data
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance.managedObjectContext
    }
    
    // MARK: FetchedResults Controller and Delegate Methods
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Trip")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "venueID == %@", self.venueID);
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
    }()
    

    func startSpinning(){
        spinner.startAnimating()
        spinnerView.hidden = false
    }
    
    func stopSpinning(){
        spinnerView.hidden = true
        spinner.stopAnimating()
    }

}
