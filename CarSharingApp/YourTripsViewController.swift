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
    var refreshControl: UIRefreshControl!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var yourTripsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Initialize a Refresh Control
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        // add refresh control to table view
        yourTripsTableView.insertSubview(refreshControl, at: 0)
        
        refresh()
        
        yourTripsTableView.dataSource = self
        yourTripsTableView.delegate = self
        
        //change color of Nav bar
        let myColor = UIColor(red: 254.0/255.0, green: 104.0/255.0, blue: 106.0/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = myColor
        
    }
    
    //====== PULL TO REFRESH =======
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        refresh()
    }
    
    func refresh() {
        activityIndicator.startAnimating()
        let currentUser = PFUser.current()
        let query = PFQuery(className: "Trip")
        query.includeKey("Name")
        query.includeKey("Members")
        query.whereKey("Members", equalTo: currentUser)
        query.findObjectsInBackground { (trips: [PFObject]?, error: Error?) in
            if let trips = trips {
                self.yourTrips.removeAll()
                for trip in trips {
                    if let tripEditId = trip["EditID"] as? String { //get EditID so that the trip won't show if it's an edit
                        if(tripEditId != "-1"){ //only add trip to the feed if it's NOT an edit
                            self.yourTrips.append(trip)
                        } else {
                            print(error?.localizedDescription)
                        }
                    }
                    
                }
                self.yourTripsTableView.reloadData()
                self.refreshControl.endRefreshing()
                self.activityIndicator.stopAnimating()
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
            let memberNames = Helper.returnMemberNames(tripMembers: tripMembers)
            print(memberNames)
            var memberString = ""
            
            for memberName in memberNames {
                memberString += memberName
                if memberName != memberNames.last {
                    memberString += ", "
                }
            }
            cell.tripMembersLabel.text = memberString
            
            let memberProfPics = Helper.returnMemberProfPics(tripMembers: tripMembers)
            Helper.displayProfilePics(withCell: cell, withMemberPics: memberProfPics)
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
