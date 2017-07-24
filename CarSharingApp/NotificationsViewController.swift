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
            
            
            var origionalTrip = getOrigionalTrip(limboTripId: limboTripID)
            origionalTrip["EditID"] = ""
            origionalTrip.saveInBackground()
            
            //delete the limbo trip
            deleteTrip(trip: limboTrip)
            
        }
    }
    
    @IBAction func didTapAccept(_ sender: AnyObject) {
        print("Chose Accept")
        if let cell = sender.superview??.superview as? EditedTripCell {
            let indexPath = tableView.indexPath(for: cell)
            let limboTrip = limboTrips[(indexPath?.row)!]
            var approvalList = limboTrip["Approvals"] as! [PFUser]
            approvalList.append(PFUser.current()!)
            limboTrip["Approvals"] = approvalList
            let limboTripID = limboTrip.objectId!
            limboTrip.saveInBackground(block: { (success: Bool, error: Error?) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("You sucessfully accepted the trip!")
                }
            })
            
            let origionalTrip = getOrigionalTrip(limboTripId: limboTripID)
            self.checkIfAllApprove(limboTrip: limboTrip, origionalTrip: origionalTrip)
            
        }

    }
    
    
    /*
     * Adds the user to the trip members list, adds the trip to the user trip list
     */
    func addUserToTrip(user: PFUser, trip: PFObject) {
        //Update for user
        var userTrips = user["MyTrips"] as! [PFObject]
        userTrips.append(trip)
        user["MyTrips"] = userTrips
        user.saveInBackground()
        
        //Update for trip
        var userList = trip["Members"] as! [PFUser]
        userList.append(user)
        trip["Members"] = userList
        trip.saveInBackground()
    }
    
    /*
     * Removes the user to the trip members list, removes the trip to the user trip list
     */
    func removeUserFromTrip(user: PFUser, trip: PFObject) {
        //Update for user
        var userTrips = user["MyTrips"] as! [PFObject]
        let tripIndex = userTrips.index(of: trip)
        userTrips.remove(at: tripIndex!)
        user["MyTrips"] = userTrips
        user.saveInBackground()
        
        //Update for trip
        var userList = trip["Members"] as! [PFUser]
        let userIndex = userList.index(of: user)
        userList.remove(at: userIndex!)
        trip["Members"] = userList
        trip.saveInBackground()
    }
    
    /*
     * Deletes the trip from the user's list of trips
     * Deletes the trip from parse
    */
    func deleteTrip(trip: PFObject) {
        let membersList = trip["Members"] as! [PFUser]
        for member in membersList {
            removeUserFromTrip(user: member, trip: trip)
        }
        trip.deleteInBackground(block: { (success: Bool, error: Error?) in
            if let error = error {
                print(error.localizedDescription)
            } else if success == true{
                print("trip denied !")
            }
        })
    }
    
    /*
     * Returns the origional trip assocaited with the given tripID string
     */
    func getOrigionalTrip(limboTripId: String) -> PFObject {
        let originalTripID = originalNameDict[limboTripId]
        let query = PFQuery(className: "Trip")
        var trip = PFObject()
        query.includeKey("Members")
        query.includeKey("EditID")
        query.whereKey("_id", equalTo: originalTripID)
        query.findObjectsInBackground(block: { (trips: [PFObject]?, error: Error?) in
            if let trips = trips {
                trip = trips[0]
            } else {
                print(error?.localizedDescription)
            }
        })
        return trip
    }
    
    /*
     * Publishes the edited trip as an actual trip and deletes the old trip
     */
    func replaceOldWithEdit(newTrip: PFObject, oldTrip: PFObject) {
        
        let membersList = newTrip["Members"] as! [PFUser]
        newTrip["Approvals"] = []
        newTrip["EditID"] = ""
        newTrip.saveInBackground()
        
        for member in membersList {
            addUserToTrip(user: member, trip: newTrip)
            removeUserFromTrip(user: member, trip: oldTrip)
        }
    }
    
    /*
     * Checks if all of the users have approved the edited trip
     */
    func checkIfAllApprove(limboTrip: PFObject, origionalTrip: PFObject) {
        let membersList = origionalTrip["Members"] as! [PFUser]
        let approvalList = limboTrip["Approvals"] as! [PFUser]
        if(membersList == approvalList) {
            replaceOldWithEdit(newTrip: limboTrip, oldTrip: origionalTrip)
            deleteTrip(trip: origionalTrip)
            
        }
    }
}
