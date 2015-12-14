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
        
        /*
        
        // Putting the buttons in the right place
        let pinBtn : UIBarButtonItem = UIBarButtonItem(image: pinImg,  style: UIBarButtonItemStyle.Plain, target: self, action: Selector("pinBtnPressed:"))
        let refreshBtn = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: Selector("refreshBtnPressed:"))
        
        let buttons : NSArray = [refreshBtn,pinBtn]
        self.navigationItem.rightBarButtonItems = buttons as? [UIBarButtonItem]
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("logoutBtnPressed:"))
        
        */
        
        
    }
    
    func refreshUI(locationDetails:W2GLocationDetailed){
        venueNameLabel.text = locationDetails.name
        self.locationDetails = locationDetails

        coverPhotoImageView.imageURL = locationDetails.coverPhoto!
        
        tableData = [[String]]()
        tableData!.insert(["\(locationDetails.rating!) / 10" ?? "No rating found"], atIndex: 0)
        tableData!.insert(["Tel: \(locationDetails.phoneNumber!)" ?? "No phone number found"], atIndex: 1)
        for addressLine in locationDetails.address! {
            tableData![1].append(addressLine)
        }
        tableData![1].append(locationDetails.websiteAddress!)
 
        tableData!.insert(locationDetails.openingHours!, atIndex: 2)
    
        placeDetailTable.reloadData()
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
        else {
            cell.textLabel?.text = "I am cell: \(indexPath.section) , \(indexPath.row)"
        }
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 1
        case 1: return tableData?[1].count ?? 0
        case 2: return tableData?[2].count ?? 0
        case 3: return 0
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
