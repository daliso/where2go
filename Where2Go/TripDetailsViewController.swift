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
    var parent:UIViewController? = nil

    // MARK: ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tripNotesTextView.layer.borderWidth = 1
        tripNotesTextView.layer.borderColor = UIColor.blackColor().CGColor
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
        
        configureUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.addKeyboardDismissRecognizer()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.removeKeyboardDismissRecognizer()
    }
    
    // MARK UI Configuration
    func configureUI(){
        if let _ = theTrip {
            datePicker.date = theTrip!.dateTime!
            tripNotesTextView.text = theTrip!.notes!
            navTitle.title = "Edit Trip Details"
            deleteTripButton.hidden = false
        } else {
            deleteTripButton.hidden = true
        }
    }
    
    // MARK: IBActions
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func saveButtonPressed(sender: UIBarButtonItem) {
        
        if theTrip == nil {
            let dictionary: [String : AnyObject] = [
                Trip.Keys.dateTime : datePicker.date,
                Trip.Keys.notes : tripNotesTextView.text,
                Trip.Keys.venueID: (parent as! PlacesDetailViewController).venueID,
                Trip.Keys.venueName: (parent as! PlacesDetailViewController).locationDetails?.name ?? ""
            ]
            
            let _ = Trip(dictionary: dictionary, context: sharedContext)
        } else {
            theTrip!.dateTime = datePicker.date
            theTrip!.notes = tripNotesTextView.text
        }
        
        CoreDataStackManager.sharedInstance.saveContext()
        
        presentingViewController?.dismissViewControllerAnimated(true
            , completion: nil)
        
    }
    
    @IBAction func deleteTripButtonPressed(sender: UIButton) {
        sharedContext.deleteObject(self.theTrip!)
        CoreDataStackManager.sharedInstance.saveContext()
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
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
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    
}
