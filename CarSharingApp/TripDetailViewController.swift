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

    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var name1Label: UILabel!
    @IBOutlet weak var name2Label: UILabel!
    @IBOutlet weak var name3Label: UILabel!
    @IBOutlet weak var name4Label: UILabel!
    @IBOutlet weak var earliestLabel: UILabel!
    @IBOutlet weak var latestLabel: UILabel!
    @IBOutlet weak var departureLocLabel: UILabel!
    @IBOutlet weak var arrivalLocLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let trip = trip {
            tripNameLabel.text = trip["Name"] as! String
            earliestLabel.text = trip["EarliestTime"] as! String
            latestLabel.text = trip["LatestTime"] as! String
            departureLocLabel.text = trip["DepartureLoc"] as! String
            arrivalLocLabel.text = trip["ArrivalLoc"] as! String
            let members = trip["Members"] as! [PFUser]
            let memberNames = returnMemberNames(tripMembers: members)
            print(memberNames)
        }
        
        
    }//close viewDidLoad()

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
                    trip?.saveInBackground(block: { (success: Bool, error: Error?) in
                        if let error = error {
                            print(error.localizedDescription)
                        } else if success{
                            print("😆success! updated trip to add new member")
                            //self.tripsTableView.reloadData()
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
    


}
