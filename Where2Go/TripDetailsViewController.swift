//
//  TripDetailsViewController.swift
//  Where2Go
//
//  Created by Daliso Zuze on 01/12/2015.
//  Copyright © 2015 Daliso Zuze. All rights reserved.
//

import UIKit
import CoreData

class TripDetailsViewController: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var tripNotesTextView: UITextView!
    @IBOutlet weak var navTitle: UINavigationItem!
    @IBOutlet weak var deleteTripButton: UIButton!
    
    // MARK: Vars
    var tapRecognizer: UITapGestureRecognizer? = nil
    var theTrip:Trip? = nil
    var parent2:UIViewController? = nil

    // MARK: ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tripNotesTextView.layer.borderWidth = 1
        tripNotesTextView.layer.borderColor = UIColor.black.cgColor
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(TripDetailsViewController.handleSingleTap(_:)))
        tapRecognizer?.numberOfTapsRequired = 1
        
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.addKeyboardDismissRecognizer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.removeKeyboardDismissRecognizer()
    }
    
    // MARK UI Configuration
    func configureUI(){
        if let _ = theTrip {
            datePicker.date = theTrip!.dateTime! as Date
            tripNotesTextView.text = theTrip!.notes!
            navTitle.title = Constants.editTripNavTitle
            deleteTripButton.isHidden = false
        } else {
            deleteTripButton.isHidden = true
        }
    }
    
    // MARK: IBActions
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        
        if theTrip == nil {
            let dictionary: [String : AnyObject] = [
                Trip.Keys.dateTime : datePicker.date as AnyObject,
                Trip.Keys.notes : tripNotesTextView.text as AnyObject,
                Trip.Keys.venueID: (parent2 as! PlacesDetailViewController).venueID as AnyObject,
                Trip.Keys.venueName: (parent2 as! PlacesDetailViewController).locationDetails?.name as AnyObject? ?? "" as AnyObject
            ]
            
            let _ = Trip(dictionary: dictionary, context: sharedContext)
        } else {
            theTrip!.dateTime = datePicker.date
            theTrip!.notes = tripNotesTextView.text
        }
        
        CoreDataStackManager.sharedInstance.saveContext()
        
        presentingViewController?.dismiss(animated: true
            , completion: nil)
        
    }
    
    @IBAction func deleteTripButtonPressed(_ sender: UIButton) {
        sharedContext.delete(self.theTrip!)
        CoreDataStackManager.sharedInstance.saveContext()
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Core Data
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance.managedObjectContext
    }
    
    // MARK: GestureRecognizer
    func addKeyboardDismissRecognizer() {
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        self.view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap(_ recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    // MARK: Constants
    fileprivate struct Constants {
        static let editTripNavTitle = "Edit Trip Details"
    }
}
