//
//  NotificationsViewController.swift
//  CarSharingApp
//
//  Created by Annabel Strauss on 7/13/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import UIKit
import Parse

class NotificationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var limboTrips: [PFObject] = []
    var refreshControl: UIRefreshControl!
    @IBOutlet weak var tableView: UITableView!
    var originalNameDict: [String: String] = [:] //[editedTripID: tripName]
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Initialize a Refresh Control
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        // add refresh control to table view
        tableView.insertSubview(refreshControl, at: 0)
        
        fetchTripsInLimbo()
        
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //====== PULL TO REFRESH =======
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        fetchTripsInLimbo()
    }
    
    func fetchTripsInLimbo() {
        activityIndicator.startAnimating()
        let currentUser = PFUser.current()
        let myTrips = currentUser?["myTrips"] as! [PFObject]
        let query = PFQuery(className: "Trip")
        query.includeKey("Name")
        query.includeKey("Members")
        query.whereKey("Members", equalTo: currentUser)
        query.findObjectsInBackground { (trips: [PFObject]?, error: Error?) in
            if let trips = trips {
                self.limboTrips.removeAll()
                for trip in trips {
                    if let tripEditId = trip["EditID"] as? String {
                        if(tripEditId != "-1" && tripEditId != ""){
                            print("print's edit id: \(tripEditId)")
                            self.originalNameDict[tripEditId] = trip["Name"] as? String //fill in dictionary so each editID knows its original trip's name
                            print(self.originalNameDict[tripEditId])
                        } else if tripEditId == "-1" {
                            self.limboTrips.append(trip) //if it's an edit, add it
                        }
                    }
                }
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
                self.activityIndicator.stopAnimating()
            } else {
                print(error?.localizedDescription)
            }
        }
    }
    
    /*
     * Sets up the cells
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditedTripCell", for: indexPath) as! EditedTripCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        let trip = limboTrips[indexPath.row]
        
        let tripName = trip["Name"] as! String
        let departureLocation = trip["DepartureLoc"] as! String
        let arrivalLocation = trip["ArrivalLoc"] as! String
        let earliestDepart = trip["EarliestTime"] as! String
        let latestDepart = trip["LatestTime"] as! String
        //print(trip.objectId!)
        if let origName = originalNameDict[trip.objectId!] {
            print(origName)
            cell.originalTripNameLabel.text = origName
        }
        if let tripMembers = trip["Members"] as? [PFUser] {
            let memberNames = returnMemberNames(tripMembers: tripMembers)
            var memberString = ""
            
            for memberName in memberNames {
                memberString += memberName
                if memberName != memberNames.last {
                    memberString += ", "
                }
            }
            cell.tripMembersLabel.text = memberString
        }
        
        
        cell.newTripNameLabel.text = tripName
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
        return limboTrips.count
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
    
    @IBAction func didTapDeny(_ sender: AnyObject) {
        if let cell = sender.superview??.superview as? TripCell {
            let indexPath = tableView.indexPath(for: cell)
            let limboTrip = limboTrips[(indexPath?.row)!]
            let limboTripID = limboTrip.objectId!
            let originalTripID = originalNameDict[limboTripID]
            
            //get actual orig trip, then change its edit id to ""
            let query = PFQuery(className: "Trip")
            query.includeKey("EditID")
            query.whereKey("_id", equalTo: originalTripID)
            query.findObjectsInBackground(block: { (trips: [PFObject]?, error: Error?) in
                if let trips = trips {
                    let trip = trips[0] 
                    trip["EditID"] = ""
                    trip.saveInBackground()
                } else {
                    print(error?.localizedDescription)
                }
            })
            
            //delete the limbo trip
            limboTrip.deleteInBackground(block: { (success: Bool, error: Error?) in
                if let error = error {
                    print(error.localizedDescription)
                } else if success == true{
                    print("trip denied !")
                }
            })
            
            //TODO: remove the limbo trip from each members list of trips
            
        }
    }
    
    @IBAction func didTapAccept(_ sender: AnyObject) {
        if let cell = sender.superview??.superview as? TripCell {
            let indexPath = tableView.indexPath(for: cell)
            let limboTrip = limboTrips[(indexPath?.row)!]
            var approvalList = limboTrip["Approvals"] as! [PFUser]
            approvalList.append(PFUser.current()!)
            limboTrip["Approvals"] = approvalList
            limboTrip.saveInBackground(block: { (success: Bool, error: Error?) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("You sucessfully accepted the trip!")
                }
            })
            
        }
        
        //TODO get origional trip, get list of members in that trip, check if edittrip[approvals]== ogtrip[members] if so then replace og trip with editied trip
        //delete og trip, clear the edit id for the edited trip and set edited trip[members] = edittrip[approvals] then clear the approvals array

    }
    
    func checkIfAllApprove(limboTrip: Trip, origionalTrip: Trip) {
        
    }
}
