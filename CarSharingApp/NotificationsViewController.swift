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
    var requests: [PFObject] = []
    var generalNotifs: [PFObject] = []
    var listOfEditIds: [String] = []
    var everythingArray: [PFObject] = []
    var refreshControl: UIRefreshControl!
    var noNotifs: Bool = false
    @IBOutlet weak var tableView: UITableView!
    var originalNameDict: [String: [String]] = [:] //[editedTripID: tripName]
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var noLimbos: Bool = false
    var noRequests: Bool = false
    var limboFetchDone: Bool = false
    var requestsFetchDone: Bool = false
    @IBOutlet weak var emojiView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emojiView.isHidden = true
        
        //Initialize a Refresh Control
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        // add refresh control to table view
        tableView.insertSubview(refreshControl, at: 0)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        fetchTripsInLimbo()
        fetchRequests()
        //fetchGeneralNotifs()
        
        //set background and text color of Nav bar
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = Helper.coral()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        emojiView.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //====== PULL TO REFRESH =======
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        everythingArray.removeAll()
        emojiView.isHidden = true
        fetchTripsInLimbo()
        fetchRequests()
        //fetchGeneralNotifs()
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
                print(error?.localizedDescription ?? "Unknown Error")
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
        }
        self.limboTrips.removeAll()
        for editID in self.listOfEditIds { //go thru list of edit ids to get each limbo trip with that id
            let query = PFQuery(className: "Trip")
            query.whereKey("objectId", equalTo: editID)
            query.addDescendingOrder("createdAt")
            query.includeKey("createdAt")
            query.findObjectsInBackground(block: { (returnedLimboTrips: [PFObject]?, error: Error?) in
                if let returnedLimboTrips = returnedLimboTrips {
                    let limbotrip = returnedLimboTrips[0]
                    if(self.shouldDisplayTrip(trip: limbotrip)) {
                        self.limboTrips.append(limbotrip) //add the fetched limbo trip to the list for the tableview
                        self.everythingArray.append(limbotrip)
                        self.sortEverythingArray()
                    }
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                    self.activityIndicator.stopAnimating()
                } else {
                    print("HELLO ERROR: \(error?.localizedDescription ?? "Unknown Error")")
                }
            })
        }
        
        
    }//close fillLimboTripList()
    
    /*
     * Get the requests for the table view
     */
    func fetchRequests() {
        let query = PFQuery(className: "Request")
        query.whereKey("TripPlannerID", equalTo: PFUser.current()!.objectId!)
        query.includeKey("User")
        query.includeKey("Trip")
        query.includeKey("createdAt")
        query.addDescendingOrder("createdAt")
        query.findObjectsInBackground { (returnedRequests: [PFObject]?, error: Error?) in
            if let returnedRequests = returnedRequests {
                self.requests.removeAll()
                for request in returnedRequests {
                    let trip = request["Trip"] as! PFObject
                    let memberArray = trip["Members"] as! [PFUser]
                    let memberCount = memberArray.count
                    if memberCount < 4 { //only add this request to the table view if the trip isn't full
                        self.requests.append(request)
                        self.everythingArray.append(request)
                        self.sortEverythingArray()
                    } else { //if the trip is full, delete this request
                        request.deleteInBackground(block: { (success: Bool, error: Error?) in
                            if let error = error {
                                print(error.localizedDescription)
                            } else {
                                print("deleted request bc trip was full 🐸")
                            }
                        })
                        //TODO: send notif to user to say trip got full
                    }
                }
                if self.requests.isEmpty {
                    self.noRequests = true
                    if self.limboTrips.isEmpty {
                        Helper.displayEmptyTableView(withTableView: self.tableView, withText: "No notifications to display!")
                        self.emojiView.isHidden = false
                    }
                }
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            } else {
                
                print("Error: \(error?.localizedDescription ?? "Unknown Error")")
            }
        }
    }
    
    /*
     * Get the general notifications for the table view
     */
    func fetchGeneralNotifs() {
        let query = PFQuery(className: "GeneralNotification")
        //idk what to query on
    }
    
    func sortEverythingArray() {
        everythingArray.sort(by: { (first: PFObject, second: PFObject) -> Bool in
            (first.createdAt!) > (second.createdAt!)
        })
    }
    
    /*
     * Sets up the cells
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let thing = everythingArray[indexPath.row]
        if thing.parseClassName == "Trip" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditedTripCell", for: indexPath) as! EditedTripCell
            cell.selectionStyle = UITableViewCellSelectionStyle.none //makes it so you can't click on the cell
            if(limboTrips.count != 0) {
                let trip = everythingArray[indexPath.row]
                let tripName = trip["Name"] as! String
                let departureLocation = trip["DepartureLoc"] as! String
                let arrivalLocation = trip["ArrivalLoc"] as! String
                let earlyDate = trip["EarliestDate"] as! NSDate
                let lateDate = trip["LatestDate"] as! NSDate
                
                let earlyStr = Helper.dateToString(date: earlyDate)
                let lateStr = Helper.dateToString(date: lateDate)
                //print(trip.objectId!)
                if let origName = originalNameDict[trip.objectId!]?[1] {
                    print(origName)
                    cell.originalTripNameLabel.text = origName.capitalized
                }
                
                cell.newTripNameLabel.text = tripName.capitalized
                cell.departLabel.text = departureLocation
                cell.destinationLabel.text = arrivalLocation
                cell.earlyTimeLabel.text = earlyStr
                cell.lateDepartLabel.text = lateStr
            }
            return cell
        }
        else if thing.parseClassName == "Request" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath) as! RequestCell
            cell.selectionStyle = UITableViewCellSelectionStyle.none //makes it so you can't click on the cell
            let request = everythingArray[indexPath.row]
            let trip = request["Trip"] as! PFObject
            let user = request["User"] as! PFUser
            let newTime = request["NewTime"] as! NSDate
            let newTimeStr = Helper.dateToString(date: newTime)
            let tripName = trip["Name"] as! String
            let userName = user["fullname"] as! String
            
            //create the string with attributed text so that you can change colors of words
            let coralAttribute = [NSForegroundColorAttributeName: Helper.coral(), NSFontAttributeName:UIFont(name: "Avenir Next", size: 16.0)!]
            let userNameAttr = NSMutableAttributedString(string: userName.capitalized, attributes: coralAttribute)
            let tripNameAttr = NSMutableAttributedString(string: tripName.capitalized, attributes: coralAttribute)
            let newTimeAttr = NSMutableAttributedString(string: newTimeStr, attributes: coralAttribute)
            let finalMessage = NSMutableAttributedString()
            finalMessage.append(userNameAttr)
            finalMessage.append(NSMutableAttributedString(string: " has requested to join your trip, "))
            finalMessage.append(tripNameAttr)
            finalMessage.append(NSMutableAttributedString(string: ", with a latest departure time of "))
            finalMessage.append(newTimeAttr)
            cell.newUserName.attributedText = finalMessage
            
            
            return cell
        }
        return UITableViewCell()
    }//close cellForRowAt
    
    
    
    /*
     * Tells the tableview how many rows should be in each section
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return everythingArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    /*
     * 1 section for requests, 1 section for edit trips, 1 section for general notifications
     */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /*
     * Determines the height of the sections
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if everythingArray[indexPath.row].parseClassName == "Trip" {
            return 179
        } else if everythingArray[indexPath.row].parseClassName == "Request" {
            return 147
        }
        return 0
    }
    
    /*
     * If a user denies a trip edit, that edit is deleted and the original trip
     * is set back to having no corressponding edit
     */
    @IBAction func didTapDeny(_ sender: AnyObject) {
        if let cell = sender.superview??.superview as? EditedTripCell {
            let indexPath = tableView.indexPath(for: cell)
            let limboTrip = everythingArray[(indexPath?.row)!]
            let limboTripID = limboTrip.objectId!
            
            
            getOrigionalTrip(limboTripId: limboTripID, withCompletion: { (origionalTrip: PFObject?, error: Error?) in
                if let origionalTrip = origionalTrip {
                    origionalTrip["EditID"] = "" //reset original trip's edit id
                    origionalTrip.saveInBackground()
                } else {
                    print(error?.localizedDescription ?? "Unknown Error")
                }
                
            })
            //delete the limbo trip
            Helper.deleteTrip(trip: limboTrip)
            self.fetchTripsInLimbo()
            self.fetchRequests()
            
        }
    }
    
    /*
     * If a user accepts a trip edit, make the trip edit the actual trip and delete the
     * original trip
     */
    @IBAction func didTapAccept(_ sender: AnyObject) {
        print("Chose Accept")
        if let cell = sender.superview??.superview as? EditedTripCell {
            let indexPath = tableView.indexPath(for: cell)
            let limboTrip = everythingArray[(indexPath?.row)!]
            var approvalList = limboTrip["Approvals"] as! [PFUser]
            print("before \(approvalList)")
            approvalList.append(PFUser.current()!)
            print("after \(approvalList)")
            limboTrip["Approvals"] = approvalList
            
            limboTrip.saveInBackground(block: { (success: Bool, error: Error?) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("You sucessfully accepted the trip!")
                    self.fetchTripsInLimbo()
                    self.fetchRequests()
                }
            })
            
            let limboTripID = limboTrip.objectId!
            getOrigionalTrip(limboTripId: limboTripID, withCompletion: { (origionalTrip: PFObject?, error: Error?) in
                if let origionalTrip = origionalTrip {
                    self.checkIfAllApprove(limboTrip: limboTrip, origionalTrip: origionalTrip)
                } else {
                    print(error?.localizedDescription ?? "Unknown Error")
                }
                
            })
        }
    }
    
    
    /*
     * If the Trip Planner denies the request to join trip, delete that request
     */
    @IBAction func didTapDenyRequest(_ sender: AnyObject) {
        if let cell = sender.superview??.superview as? RequestCell {
            let indexPath = tableView.indexPath(for: cell)
            let request = everythingArray[(indexPath?.row)!]
            request.deleteInBackground(block: { (success: Bool, error: Error?) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("Sucessfully deleted the request 🐞")
                    self.fetchTripsInLimbo()
                    self.fetchRequests()
                }
            })
        }
    }
    
    /*
     * If the Trip Planner accepts the request to join trip, update the trip to have this
     * new member and new time, and delete the request
     */
    @IBAction func didTapAcceptRequest(_ sender: AnyObject) {
        if let cell = sender.superview??.superview as? RequestCell {
            let indexPath = tableView.indexPath(for: cell)
            let request = everythingArray[(indexPath?.row)!]
            let newUser = request["User"] as! PFUser
            let newTime = request["NewTime"] as! NSDate
            let trip = request["Trip"] as! PFObject
            let oldMembersArray = trip["Members"] as! [PFUser]
            var membersArray = trip["Members"] as! [PFUser]
            membersArray.append(newUser)
            trip["Members"] = membersArray //update trip's members to have the request user
            trip["LatestDate"] = newTime //change the latest time of the trip
            //save the trip
            trip.saveInBackground(block: { (success: Bool, error: Error?) in
                if let error = error {
                    print(error.localizedDescription)
                } else if success{
                    print("😆success! request accepted and trip updated")
                    self.notifyTripMembersAboutNewMember(withTrip: trip, withMembers: oldMembersArray) //send notification to other trip members
                }
            })
            //delete the request
            request.deleteInBackground(block: { (success: Bool, error: Error?) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("Sucessfully deleted the request 🐞")
                    self.fetchTripsInLimbo()
                    self.fetchRequests()
                }
            })
            
        }
    }
    
    func notifyTripMembersAboutNewMember(withTrip trip: PFObject, withMembers members: [PFUser]) {
        GeneralNotification.postGeneralNotification(withTrip: trip, withUserList: members, withMessage: "Someone just joined a trip that you're in!") { (notification: PFObject?, error: Error?) in
            if let error = error {
                print(error.localizedDescription)
            } else if let notification = notification {
                print("notification created 🐤")
            }
        }
    }
    
    /*
     * Adds the user to the trip members list, adds the trip to the user trip list
     */
    func addUserToTrip(user: PFUser, trip: PFObject) {
        //Update for trip
        var userList = trip["Members"] as! [PFUser]
        userList.append(user)
        trip["Members"] = userList
        //trip.saveInBackground()
    }
    
    /*
     * Returns the origional trip assocaited with the given tripID string
     */
    func getOrigionalTrip(limboTripId: String, withCompletion completion: @escaping (PFObject?, Error?) -> ()) {
        let originalTripID = originalNameDict[limboTripId]?[0]
        let query = PFQuery(className: "Trip")
        var trip: PFObject?
        query.whereKey("objectId", equalTo: originalTripID)
        query.findObjectsInBackground(block: { (trips: [PFObject]?, error: Error?) in
            if let trips = trips {
                trip = trips[0]
                completion(trip, nil)
            } else {
                print(error?.localizedDescription ?? "Unknown Error")
            }
        })
    }
    
    /*
     * Publishes the edited trip as an actual trip and deletes the old trip
     */
    public func replaceOldWithEdit(newTrip: PFObject, oldTrip: PFObject) {
        
        let membersList = oldTrip["Members"] as! [PFUser]
        newTrip["Approvals"] = []
        newTrip["EditID"] = ""
        newTrip.saveInBackground()
        
        var memberObjectIds = [String]()
        for member in membersList {
            memberObjectIds.append(member.objectId!)
            
        }
        
        let query = PFQuery(className: "_User")
        query.whereKey("objectId", containedIn: memberObjectIds)
        query.findObjectsInBackground(block: { (members: [PFObject]?, error: Error?) in
            if let members = members {
                for member in members {
                    self.addUserToTrip(user: member as! PFUser, trip: newTrip)
                }
                
                newTrip.saveInBackground(block: { (success: Bool, error: Error?) in
                    if success == true {
                        print("Saved all members to trip!")
                    } else {
                        print("error description 1: \(error?.localizedDescription)")
                    }
                })
            } else {
                print("error description 2: \(error?.localizedDescription ?? "Unknown Error")")
            }
        })
        
    }
    
    /*
     * Checks if all of the users have approved the edited trip
     */
    func checkIfAllApprove(limboTrip: PFObject, origionalTrip: PFObject) {
        let membersList = origionalTrip["Members"] as! [PFUser]
        let approvalList = limboTrip["Approvals"] as! [PFUser]
        if(listsAreEqual(memberList: membersList, approvalList: approvalList)) {
            Helper.deleteTrip(trip: origionalTrip)
            self.tableView.reloadData()
            replaceOldWithEdit(newTrip: limboTrip, oldTrip: origionalTrip)
            
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
}
