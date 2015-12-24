//
//  DisplayTripDetailsViewController.swift
//  Where2Go
//
//  Created by Daliso Zuze on 23/12/2015.
//  Copyright © 2015 Daliso Zuze. All rights reserved.
//

import UIKit
import CoreData

class DisplayTripDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {

    
    @IBOutlet weak var displayTripView: UITableView!
    var theTrip:Trip?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let editTripButton : UIBarButtonItem = UIBarButtonItem(title: "Edit Trip", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("editTripButtonPressed:"))
        self.navigationItem.rightBarButtonItem = editTripButton
        
        displayTripView.dataSource = self
        displayTripView.delegate = self

    }
    
    override func viewDidLayoutSubviews() {
        displayTripView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 49.0, right: 0.0)
        print("Content Inset=\(displayTripView.contentInset) , Content Offset=\(displayTripView.contentOffset)")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func editTripButtonPressed(sender: AnyObject){
    }
    
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
                cell!.textLabel?.text = theTrip?.venueName ?? "No Trip Obbject Set"
            } else {
                cell!.textLabel?.text = theTrip?.venueName ?? "No Trip Obbject Set"
            }
            return cell!
            
        case 1:
            var cell = tableView.dequeueReusableCellWithIdentifier("TripDateTimeCell")
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "TripLocationCell")
                let timestamp = NSDateFormatter.localizedStringFromDate(theTrip?.dateTime! ?? NSDate(), dateStyle: .FullStyle, timeStyle: .ShortStyle)
                cell!.textLabel?.text = "\(timestamp)"
                
            } else {
                let timestamp = NSDateFormatter.localizedStringFromDate(theTrip?.dateTime! ?? NSDate(), dateStyle: .FullStyle, timeStyle: .ShortStyle)
                cell!.textLabel?.text = "\(timestamp)"
            }
            return cell!
        case 2:
            var cell = tableView.dequeueReusableCellWithIdentifier("TripNotesCell")
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "TripLocationCell")
                cell!.textLabel?.text = theTrip?.notes ?? "No Trip Object Set"
            } else {
                cell!.textLabel?.text = theTrip?.notes ?? "No Trip Object Set"
            }
            return cell!
        default:
            return UITableViewCell()
        }

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
    
   
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
