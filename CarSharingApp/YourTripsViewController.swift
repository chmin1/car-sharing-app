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
        //HOW TO QUERY AN ARRAY
        
        let currentUser = PFUser.current()
        let myTrips = currentUser?["myTrips"] as! [PFObject]
        let query = PFQuery(className: "Trip")
        query.includeKey("Name")
        query.includeKey("Members")
        query.whereKey("Members", equalTo: currentUser)
        query.findObjectsInBackground { (trips: [PFObject]?, error: Error?) in
            if let trips = trips {
                self.yourTrips.removeAll()
                for trip in trips {
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
        print("depart: \(departureLocation)")
        print("arriv: \(arrivalLocation)")
        print("earliestdep: \(earliestDepart)")
        print("latestdep: \(latestDepart)")
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
        return yourTrips.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
    
    
    //====== SEGUE TO DETAIL VIEW =======
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        if let indexPath = yourTripsTableView.indexPath(for: cell) {//get this to find the actual trip
            let trip = yourTrips[indexPath.row] //get the trip
            let detailViewController = segue.destination as! TripDetailViewController //tell it its destination
            detailViewController.trip = trip
        }
    }
    
}
