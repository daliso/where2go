//
//  MyPlacesViewController.swift
//  Where2Go
//
//  Created by Daliso Zuze on 10/10/2015.
//  Copyright © 2015 Daliso Zuze. All rights reserved.
//

import UIKit

class MyPlacesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {

    @IBOutlet weak var myTripsTable: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        myTripsTable.delegate = self
        myTripsTable.dataSource = self
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
        return "This is a section header"
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        let height:CGFloat = 60
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
