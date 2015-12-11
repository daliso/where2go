//
//  PlacesDetailViewController.swift
//  Where2Go
//
//  Created by Daliso Zuze on 10/10/2015.
//  Copyright © 2015 Daliso Zuze. All rights reserved.
//

import UIKit

class PlacesDetailViewController: UIViewController,  UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var placeDetailTable: UITableView!
    @IBOutlet weak var venueNameLabel: UILabel!
    @IBOutlet weak var coverPhotoImageView: URLImageView!
    
    var venueID:String = "49ecf7f1f964a520ba671fe3"
    
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
    }
    
    func refreshUI(locationDetails:W2GLocationDetailed){
        venueNameLabel.text = locationDetails.name
        coverPhotoImageView.imageURL = locationDetails.coverPhoto!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "I am cell: \(indexPath.section) , \(indexPath.row)"
        return cell
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 5
        case 1: return 5
        case 2: return 5
        case 3: return 5
        case 4: return 5
        default: return 4
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 5
    }
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Contact Details"
        case 1: return "Opening Hours"
        case 2: return "Rating"
        case 3: return "Photos"
        case 4: return "Reviews"
        default: return "Your Planned Trips"
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        let height:CGFloat = 30
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
