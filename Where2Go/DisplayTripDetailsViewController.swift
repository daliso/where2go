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

    // MARK: IBOutlets
    @IBOutlet weak var displayTripView: UITableView!
    
    // MARK: Vars
    var theTrip:Trip?
    
    // MARK: ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let editTripButton : UIBarButtonItem = UIBarButtonItem(title: Constants.editTripButtonTitle, style: UIBarButtonItemStyle.plain, target: self, action: #selector(DisplayTripDetailsViewController.editTripButtonPressed(_:)))
        self.navigationItem.rightBarButtonItem = editTripButton
        
        displayTripView.dataSource = self
        displayTripView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let _ = theTrip?.venueName{
            displayTripView.reloadData()
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewDidLayoutSubviews() {
        displayTripView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 49.0, right: 0.0)
    }

    // UI Event Handlers
    func editTripButtonPressed(_ sender: AnyObject){
        performSegue(withIdentifier: Constants.segueToEditTripDetailFromDisplayTrip, sender: self)
    }
    
    // MARK: TableView Deletage Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch (indexPath as NSIndexPath).section {
        case 0:
            var cell = tableView.dequeueReusableCell(withIdentifier: Constants.TripLocationCellIdentifier)
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: Constants.TripLocationCellIdentifier)
                cell!.textLabel?.text = theTrip?.venueName ?? "No Trip Obbject Set"
            } else {
                cell!.textLabel?.text = theTrip?.venueName ?? "No Trip Obbject Set"
            }
            return cell!
            
        case 1:
            var cell = tableView.dequeueReusableCell(withIdentifier: Constants.TripDateTimeCellIdentifier)
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: Constants.TripDateTimeCellIdentifier)
                let timestamp = DateFormatter.localizedString(from: theTrip?.dateTime! as Date? ?? Date(), dateStyle: .full, timeStyle: .short)
                cell!.textLabel?.text = "\(timestamp)"
                
            } else {
                let timestamp = DateFormatter.localizedString(from: theTrip?.dateTime! as Date? ?? Date(), dateStyle: .full, timeStyle: .short)
                cell!.textLabel?.text = "\(timestamp)"
            }
            return cell!
        case 2:
            var cell = tableView.dequeueReusableCell(withIdentifier: Constants.TripNotesCellIdentifier)
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: Constants.TripNotesCellIdentifier)
                cell?.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
                cell?.textLabel?.numberOfLines = 0
                cell!.textLabel?.text = theTrip?.notes ?? "No Trip Object Set"
            } else {
                cell?.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
                cell?.textLabel?.numberOfLines = 0
                cell!.textLabel?.text = theTrip?.notes ?? "No Trip Object Set"
            }
            
            return cell!
        default:
            return UITableViewCell()
        }

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Location Name"
        case 1: return "Time and Date"
        case 2: return "Trip Notes"
        default: return "default section title"
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let height:CGFloat = 50
        return height
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
   
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TripDetailsViewController {
            vc.theTrip = self.theTrip
        }
    }
    
    // MARK: Constants
    fileprivate struct Constants {
        static let editTripButtonTitle = "Edit Trip"
        static let segueToEditTripDetailFromDisplayTrip = "editTripDetailFromDisplayTrip"
        static let TripLocationCellIdentifier = "TripLocationCell"
        static let TripDateTimeCellIdentifier = "TripDateTimeCell"
        static let TripNotesCellIdentifier = "TripNotesCell"
    }
}
