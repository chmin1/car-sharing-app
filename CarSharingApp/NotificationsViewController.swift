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
    var listOfEditIds: [String] = []
    var refreshControl: UIRefreshControl!
    @IBOutlet weak var tableView: UITableView!
    var originalNameDict: [String: [String]] = [:] //[editedTripID: tripName]
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
        //get a list of the user's trips
        //update list to just have trips with edit ids that aren't ""
        //for each trip that has an edit, get the edit id
        //with that edit id, get the limbo trip
        // IN TABLE VIEW: check if user has alredy responded to the edit and don't display if they have
        
        activityIndicator.startAnimating()
        let currentUser = PFUser.current()
        let query = PFQuery(className: "Trip")
        query.includeKey("Name")
        query.includeKey("Members")
        query.whereKey("Members", equalTo: currentUser)
        query.findObjectsInBackground { (trips: [PFObject]?, error: Error?) in
            if let trips = trips {
                self.listOfEditIds.removeAll()
                for trip in trips {
                    if let tripEditId = trip["EditID"] as? String {
                        if(tripEditId != "") {
                            print("trip's edit id: \(tripEditId)")
                            var oldTripInfo = ["", ""]
                            oldTripInfo[0] = trip.objectId!
                            oldTripInfo[1] = (trip["Name"] as? String)!
                            self.originalNameDict[tripEditId] = oldTripInfo
                            
                            self.listOfEditIds.append(tripEditId) //if the trip has an edit, add that edit id to the list of edit ids
                            
                        }
                    }
                    
                }
                
                self.fillLimboTripList()
                
            } else {
                print(error?.localizedDescription)
            }
        }
    }//close fetchTripsInLimbo()
    
    /*
     * Goes thru the list of edit ids and finds the corresponding limbo trip. Then adds that
     * limbo trip to the list of limbo trips for the tableview
     */
    func fillLimboTripList() {
        if(self.listOfEditIds.count == 0){
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
            self.activityIndicator.stopAnimating()
            //TODO: maybe show something on notifications vc that says "no notifications"
        }
        for editID in self.listOfEditIds { //go thru list of edit ids to get each limbo trip with that id
            let query = PFQuery(className: "Trip")
            query.whereKey("objectId", equalTo: editID)
            query.findObjectsInBackground(block: { (returnedLimboTrips: [PFObject]?, error: Error?) in
                //Code below is being called twice
                if let returnedLimboTrips = returnedLimboTrips {
                    self.limboTrips.removeAll()
                    let limbotrip = returnedLimboTrips[0]
                    if(self.shouldDisplayTrip(trip: limbotrip)) {
                        print("HII")
                        self.limboTrips.append(limbotrip) //add the fetched limbo trip to the list for the tableview
                    }
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                    self.activityIndicator.stopAnimating()
                } else {
                    print("HELLO ERROR: \(error?.localizedDescription)")
                }
            })
        }
    }//close fillLimboTripList()
    
    func shouldDisplayTrip(trip: PFObject) -> Bool {
        let approvalList = trip["Approvals"] as! [PFUser]
        for member in approvalList {
            let memberID = member.objectId
            if(memberID == PFUser.current()?.objectId) {
                return false;
            }
        }
        return true;
    }
    
    /*
     * Sets up the cells
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditedTripCell", for: indexPath) as! EditedTripCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        if(limboTrips.count != 0) {
            let trip = limboTrips[indexPath.row]
            let tripName = trip["Name"] as! String
            let departureLocation = trip["DepartureLoc"] as! String
            let arrivalLocation = trip["ArrivalLoc"] as! String
            let earliestDepart = trip["EarliestTime"] as! String
            let latestDepart = trip["LatestTime"] as! String
            //print(trip.objectId!)
            if let origName = originalNameDict[trip.objectId!]?[1] {
                print(origName)
                cell.originalTripNameLabel.text = origName
            }
            
            cell.newTripNameLabel.text = tripName
            cell.departLabel.text = departureLocation
            cell.destinationLabel.text = arrivalLocation
            cell.earlyTimeLabel.text = earliestDepart
            cell.lateDepartLabel.text = latestDepart
        }
        
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
        if let cell = sender.superview??.superview as? EditedTripCell {
            let indexPath = tableView.indexPath(for: cell)
            //print("Limbotrips \(limboTrips)")
            let limboTrip = limboTrips[(indexPath?.row)!]
            let limboTripID = limboTrip.objectId!
            
            
            getOrigionalTrip(limboTripId: limboTripID, withCompletion: { (origionalTrip: PFObject?, error: Error?) in
                if let origionalTrip = origionalTrip {
                    origionalTrip["EditID"] = "" //reset original trip's edit id
                    origionalTrip.saveInBackground()
                } else {
                    print(error?.localizedDescription)
                }
                
            })
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
                    self.tableView.reloadData()
                }
            })
            
            getOrigionalTrip(limboTripId: limboTripID, withCompletion: { (origionalTrip: PFObject?, error: Error?) in
                if let origionalTrip = origionalTrip {
                    self.checkIfAllApprove(limboTrip: limboTrip, origionalTrip: origionalTrip)
                } else {
                    print(error?.localizedDescription)
                }
                
            })
            
            
        }
        
    }
    
    
    /*
     * Adds the user to the trip members list, adds the trip to the user trip list
     */
    public func addUserToTrip(user: PFUser, trip: PFObject) {
        //Update for user
        var userTrips = user["myTrips"] as! [PFObject]
        userTrips.append(trip)
        user["myTrips"] = userTrips
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
    public func removeUserFromTrip(user: PFUser, trip: PFObject) {
        //Update for user
        var userTrips = user["myTrips"] as! [PFObject]
        let tripIndex = userTrips.index(of: trip)
        userTrips.remove(at: tripIndex!)
        user["myTrips"] = userTrips
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
    public func deleteTrip(trip: PFObject) {
        /* if let membersList = trip["Members"] as? [PFUser] {
         for member in membersList {
         removeUserFromTrip(user: member, trip: trip)
         }
         }
         */
        
        trip.deleteInBackground(block: { (success: Bool, error: Error?) in
            if let error = error {
                print(error.localizedDescription)
            } else if success == true{
                print("trip deleted !")
                self.tableView.reloadData()
            }
        })
    }
    
    /*
     * Returns the origional trip assocaited with the given tripID string
     */
    public func getOrigionalTrip(limboTripId: String, withCompletion completion: @escaping (PFObject?, Error?) -> ()) {
        let originalTripID = originalNameDict[limboTripId]?[0]
        let query = PFQuery(className: "Trip")
        var trip: PFObject?
        //query.includeKey("EditID")
        query.whereKey("objectId", equalTo: originalTripID)
        query.findObjectsInBackground(block: { (trips: [PFObject]?, error: Error?) in
            if let trips = trips {
                trip = trips[0]
                completion(trip, nil)
            } else {
                print(error?.localizedDescription)
            }
        })
    }
    
    /*
     * Publishes the edited trip as an actual trip and deletes the old trip
     */
    public func replaceOldWithEdit(newTrip: PFObject, oldTrip: PFObject) {
        
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
    public func checkIfAllApprove(limboTrip: PFObject, origionalTrip: PFObject) {
        let membersList = origionalTrip["Members"] as! [PFUser]
        let approvalList = limboTrip["Approvals"] as! [PFUser]
        if(listsAreEqual(memberList: membersList, approvalList: approvalList)) {
            replaceOldWithEdit(newTrip: limboTrip, oldTrip: origionalTrip)
            deleteTrip(trip: origionalTrip)
            
        }
    }
    
    func listsAreEqual(memberList: [PFUser], approvalList: [PFUser]) -> Bool {
        var memberIds = [String]()
        var approvalIds = [String]()
        
        for member in memberList {
            memberIds.append(member.objectId!)
        }
        
        for approver in approvalList {
            approvalIds.append(approver.objectId!)
        }
        
        for memberId in memberIds {
            if !approvalIds.contains(memberId) {
                return false
            }
        }
        return true
    }
}
