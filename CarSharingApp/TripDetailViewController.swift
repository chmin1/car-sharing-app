//
//  TripDetailViewController.swift
//  CarSharingApp
//
//  Created by Elan Halpern on 7/17/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import UIKit
import Parse

class TripDetailViewController: UIViewController {
    
    var trip: PFObject?
    var requestToJoinAlert: UIAlertController!
    
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var name1Label: UILabel!
    @IBOutlet weak var name2Label: UILabel!
    @IBOutlet weak var name3Label: UILabel!
    @IBOutlet weak var name4Label: UILabel!
    @IBOutlet weak var earliestLabel: UILabel!
    @IBOutlet weak var latestLabel: UILabel!
    @IBOutlet weak var departureLocLabel: UILabel!
    @IBOutlet weak var arrivalLocLabel: UILabel!
    @IBOutlet weak var member1Prof: UIImageView!
    @IBOutlet weak var member2Prof: UIImageView!
    @IBOutlet weak var member3Prof: UIImageView!
    @IBOutlet weak var member4Prof: UIImageView!
    @IBOutlet weak var requestButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var leaveButton: UIButton!
    var pendingEditAlert: UIAlertController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set up request to join alert
        setUpRequestToJoinAlert()
        
        //hide all name labels (only make them appear if there's a name to put)
        name2Label.isHidden = true
        name3Label.isHidden = true
        name4Label.isHidden = true
        
        //hide all prof pics (only make them appear if there's a member to put)
        member2Prof.isHidden = true
        member3Prof.isHidden = true
        member4Prof.isHidden = true
        
        //hide edit and leave buttons
        editButton.isHidden = true
        leaveButton.isHidden = true
        
        //make all prof pics circular
        member1Prof.layer.cornerRadius = member1Prof.frame.size.width / 2
        member1Prof.clipsToBounds = true
        member2Prof.layer.cornerRadius = member2Prof.frame.size.width / 2
        member2Prof.clipsToBounds = true
        member3Prof.layer.cornerRadius = member3Prof.frame.size.width / 2
        member3Prof.clipsToBounds = true
        member4Prof.layer.cornerRadius = member4Prof.frame.size.width / 2
        member4Prof.clipsToBounds = true
        
        //Pending Edit
        //Set up invalid trip alerts
        let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
            // handle cancel response here. Doing nothing will dismiss the view.
        }
        pendingEditAlert = UIAlertController(title: "Pending Edit", message: "There is already an edit in progress for this trip. You must wait until it is approved or denied before making another change.", preferredStyle: .alert)
        pendingEditAlert.addAction(cancelAction)
        
        if let trip = trip {
            tripNameLabel.text = trip["Name"] as! String
            earliestLabel.text = trip["EarliestTime"] as! String
            latestLabel.text = trip["LatestTime"] as! String
            departureLocLabel.text = trip["DepartureLoc"] as! String
            arrivalLocLabel.text = trip["ArrivalLoc"] as! String
            let members = trip["Members"] as! [PFUser]
            let memberNames = returnMemberNames(tripMembers: members) as [String]
            print(memberNames)
            self.fillInNamesAndProfPics(memberNames: memberNames, members: members)
            
            //hide the "request to join" button if the current user is already in that trip OR if that trip already has 4 ppl in it
            let currentMemberName = PFUser.current()?["fullname"] as! String?
            if memberNames.contains(currentMemberName!) || memberNames.count == 4 {
                requestButton.isHidden = true
            }
            //show the edit and leave buttons if the current user is in the trip
            if memberNames.contains(currentMemberName!) {
                editButton.isHidden = false
                leaveButton.isHidden = false
            }
            
        }
        
        
    }//close viewDidLoad()
    
    func fillInNamesAndProfPics(memberNames: [String?], members: [PFUser]) {
        let count = memberNames.count
        
        //fill in first person's info if count > 0
        if let member1 = memberNames[0] {
            name1Label.text = member1 //fill in their name
            //fill in their prof pic
            if let profPic = members[0]["profPic"] as? PFFile {
                profPic.getDataInBackground { (imageData: Data!, error: Error?) in
                    self.member1Prof.image = UIImage(data: imageData)
                }
            }
        }
        
        //fill in second person's info if count > 1
        if count > 1 {
            name2Label.isHidden = false
            member2Prof.isHidden = false
            if let member2 = memberNames[1] {
                name2Label.text = member2 //fill in their name
                //fill in their prof pic
                if let profPic = members[1]["profPic"] as? PFFile {
                    profPic.getDataInBackground { (imageData: Data!, error: Error?) in
                        self.member2Prof.image = UIImage(data: imageData)
                    }
                }
            }
        }
        
        //fill in third person's info if count > 2
        if count > 2 {
            name3Label.isHidden = false
            member3Prof.isHidden = false
            if let member3 = memberNames[2] {
                name3Label.text = member3 //fill in their name
                //fill in their prof pic
                if let profPic = members[2]["profPic"] as? PFFile {
                    profPic.getDataInBackground { (imageData: Data!, error: Error?) in
                        self.member3Prof.image = UIImage(data: imageData)
                    }
                }
            }
        }
        
        //fill in fourth person's info if count > 3
        if count > 3 {
            name4Label.isHidden = false
            member4Prof.isHidden = false
            if let member4 = memberNames[3] {
                name4Label.text = member4 //fill in their name
                //fill in their prof pic
                if let profPic = members[3]["profPic"] as? PFFile {
                    profPic.getDataInBackground { (imageData: Data!, error: Error?) in
                        self.member4Prof.image = UIImage(data: imageData)
                    }
                }
            }
        }
    }//close fillInNames()
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    @IBAction func didTapRequestToJoinTrip(_ sender: Any) {
        present(requestToJoinAlert, animated: true, completion: nil)
    }
    
    func setUpRequestToJoinAlert(){
        // Set up the requestToJoinAlert
        requestToJoinAlert = UIAlertController(title: "Requesting To Join Trip", message: "Are you sure you want to join this trip?", preferredStyle: .alert)
        
        let noAction = UIAlertAction(title: "No", style: .cancel) { (action) in
            // handle cancel response here. Doing nothing will dismiss the view.
        }
        
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            self.addUserToTrip()
        }
        
        requestToJoinAlert.addAction(noAction) // add the no action to the alertController
        requestToJoinAlert.addAction(yesAction) // add the yes action to the alertController
    }
    
    
    //====== ADD USER TO TRIP WHEN "REQUEST TO JOIN" IS PRESSED =======
    func addUserToTrip() {
        var membersArray = trip?["Members"] as! [PFUser]
        if membersArray.count < 4 {
            let memberNames = returnMemberNames(tripMembers: membersArray)
            if let fullname = PFUser.current()?["fullname"] {
                if memberNames.contains(fullname as! String) == false {
                    membersArray.append(PFUser.current()!)
                    trip?["Members"] = membersArray
                    
                    //add this trip to the user's list of trips and SAVE
                    if var usersTrips = PFUser.current()!["myTrips"] as? [PFObject] {
                        print(trip!)
                        usersTrips.append(trip!)
                        PFUser.current()?["myTrips"] = usersTrips
                        PFUser.current()?.saveInBackground(block: { (success: Bool, error: Error?) in
                            if let error = error {
                                print(error.localizedDescription)
                            } else if success {
                                print("😆success! updated user to add trip")
                            }
                        })
                    }
                    
                    //SAVE this updated trip into to the trip
                    trip?.saveInBackground(block: { (success: Bool, error: Error?) in
                        if let error = error {
                            print(error.localizedDescription)
                        } else if success{
                            print("😆success! updated trip to add new member")
                            self.addMemberLocally(members: membersArray, currentFullname: fullname as! String)
                        }
                    })
                    trip = nil
                } else if memberNames.contains(fullname as! String) == true{
                    print("You are already in this trip")
                }
            }
        }
        else {
            print("Can't join - this trip is already full")
        }
    }//close addUserToTrip()
    
    //====== LOCALLY ADD MEMBER TO TRIP FOR DETAIL VIEW =======
    func addMemberLocally(members: [PFUser], currentFullname: String) {
        let newCount = members.count
        if newCount == 2 {
            name2Label.isHidden = false
            member2Prof.isHidden = false
            name2Label.text = currentFullname
        }
        if newCount == 3 {
            name3Label.isHidden = false
            member3Prof.isHidden = false
            name3Label.text = currentFullname
        }
        if newCount == 4 {
            name4Label.isHidden = false
            member4Prof.isHidden = false
            name4Label.text = currentFullname
        }
    }
    
    //====== REMOVE THE USER FROM THE MEMBERS LIST OF TRIP AND REMOVE TRIP FROM TRIP LIST OF USER =======
    @IBAction func onLeaveTrip(_ sender: Any) {
        
        var membersList = trip?["Members"] as! [PFUser]
        let userIndex = membersList.index(of: PFUser.current()!)
        membersList.remove(at: userIndex!)
        trip?["Members"] = membersList
        trip?.saveInBackground(block: { (success: Bool, error:Error?) in
            if let error = error {
                print("Error removing user from Trip: \(error.localizedDescription)")
            } else {
                print("user successfully removed from trip")
            }
        })
        
        var tripList = PFUser.current()?["myTrips"] as! [PFObject]
        let tripIndex = tripList.index(of: trip!)
        tripList.remove(at: tripIndex!)
        PFUser.current()?["myTrips"] = tripList
        PFUser.current()?.saveInBackground(block: { (success: Bool, error:Error?) in
            if let error = error {
                print("Error removing trip from user's list of trips: \(error.localizedDescription)")
            } else {
                print("Successfully removed trip from user's list of trips")
            }
        })
        
        //go back to Home VC
        _ = navigationController?.popViewController(animated: true)

    }
    
    /*
    * Only allow Edit VC to open if the trip doesn't already have a corresponding edit pending
    * Otherwise, present the pending edit alert
    */
    @IBAction func didTapEdit(_ sender: Any) {
        let tripEditId = trip?["EditID"] as! String
        if tripEditId == "" { //only open edit vc if this trip doesn't have a corresponding edit
            performSegue(withIdentifier: "editSegue", sender: nil)
        } else {
            present(pendingEditAlert, animated: true) { } //present pending edit alert if there is a pending edit
        }
    }
    
    /*
     * Passes the current trip over to the Edit vc
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editSegue" {
            let editViewController = segue.destination as! EditViewController //tell it its destination
            editViewController.originalTrip = trip
        }
    }
    
    
}
