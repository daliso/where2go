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

    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var tripNotesTextView: UITextView!
    
    var tapRecognizer: UITapGestureRecognizer? = nil
    
    var theTrip:Trip? = nil
    var venueID:String? = nil
    var parent:UIViewController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tripNotesTextView.layer.borderWidth = 1
        tripNotesTextView.layer.borderColor = UIColor.blackColor().CGColor
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
    }
    
    override func viewWillAppear(animated: Bool) {
        self.addKeyboardDismissRecognizer()
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.removeKeyboardDismissRecognizer()
        self.unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: Keyboard Functions
    func keyboardWillShow(notification: NSNotification) {
       // if self.view.frame.height < 500.0 { // For iPhone 4s and below to allow the textfields to show when keyboard is displayed
       //     self.view.frame.origin.y = -150
       // }
        
      // datePicker.hidden = true
        
    }
    
    @IBAction func saveButtonPressed(sender: UIBarButtonItem) {
        //
        
        let dictionary: [String : AnyObject] = [
            Trip.Keys.dateTime : datePicker.date,
            Trip.Keys.notes : tripNotesTextView.text,
            Trip.Keys.venueID: (parent as! PlacesDetailViewController).venueID,
            Trip.Keys.venueName: (parent as! PlacesDetailViewController).locationDetails?.name ?? ""
        ]
        
        let _ = Trip(dictionary: dictionary, context: sharedContext)
        
        CoreDataStackManager.sharedInstance.saveContext()
        
        // (parent as! PlacesDetailViewController).placeDetailTable.reloadData()
        
        presentingViewController?.dismissViewControllerAnimated(true
            , completion: nil)
        
    }
    
    // MARK: Core Data
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance.managedObjectContext
    }
    
    
    func keyboardWillHide(notification: NSNotification) {
       // if self.view.frame.height < 500.0  {
       //     self.view.frame.origin.y = 0
       // }
       // datePicker.hidden = false
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:"    , name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:"    , name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillHideNotification, object: nil)
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
