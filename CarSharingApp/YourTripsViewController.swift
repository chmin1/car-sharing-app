//
//  YourTripsViewController.swift
//  CarSharingApp
//
//  Created by Annabel Strauss on 7/13/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import UIKit
import Parse

class YourTripsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var yourTrips: [PFObject] = []
    
    @IBOutlet weak var yourTripsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
        
        
        yourTripsTableView.dataSource = self
        yourTripsTableView.delegate = self
        
        
        // Do any additional setup after loading the view.
    }
    
    func refresh() {
        let query = PFQuery(className: "Trip")
        query.whereKey("Planner", equalTo: PFUser.current())
        query.includeKey("Planner")
        query.includeKey("Members")
        query.order(byDescending: "_created_at")
        query.findObjectsInBackground { (trips: [PFObject]?, error: Error?) in
            if let trips = trips {
                self.yourTrips.removeAll()
                for trip in trips {
                    print(trip)
                    self.yourTrips.append(trip)
                }
                self.yourTripsTableView.reloadData()
                //self.refreshControl.endRefreshing()
            } else {
                print(error?.localizedDescription)
            }
            
        }
    }
    
    /*
     * Sets up the cells
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripCell", for: indexPath) as! TripCell
        let trip = yourTrips[indexPath.row]
        let tripName = trip["Name"] as! String
        
        let departureLocation = trip["DepartureLoc"] as! String
        let arrivalLocation = trip["ArrivalLoc"] as! String
        let earliestDepart = trip["EarliestTime"] as! String
        let latestDepart = trip["LatestTime"] as! String
        if let tripMembers = trip["Members"] as? [PFUser] {
            print(tripName)
            let memberNames = returnMemberNames(tripMembers: tripMembers)
            print(memberNames)
            var memberString = ""
            
            for memberName in memberNames {
                memberString += memberName
                if memberName != memberNames.last {
                    memberString += ", "
                }
            }
            cell.tripMembersLabel.text = memberString
        }
        
        cell.tripName.text = tripName
        cell.departLabel.text = departureLocation
        cell.destinationLabel.text = arrivalLocation
        cell.earlyTimeLabel.text = earliestDepart
        cell.lateDepartLabel.text = latestDepart
        return cell
    }
    
    
    /*
     * Tells the tableview how many rows should be in each section
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //secion 0 has 1 row (header)
        if (section == 0) {
            return 1
        }
            //section 1 has tripsFeed.count rows
        else if (section == 1) {
            //TODO: Set this to be filteredtrips.count
            return yourTrips.count
        }
        return 0
    }
    
    //======== TURNS ARRAY OF MEMBERS FROM PFUSER TO STRING ========
    func returnMemberNames(tripMembers: [PFUser]) -> [String] {
        var memberNames: [String] = []
        for member in tripMembers {
            if let memberName = member["fullname"] as? String {
                memberNames.append(memberName)
            }
        }
        return memberNames
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
