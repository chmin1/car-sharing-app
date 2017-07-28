//
//  HalfModalViewController.swift
//  CarSharingApp
//
//  Created by Annabel Strauss on 7/28/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import UIKit
import Parse

class HalfModalViewController: UIViewController, HalfModalPresentable {

    @IBOutlet weak var myDatePicker: UIDatePicker!
    var newTime: String = ""
    var currentTrip: PFObject?
    var originalTripTime: String = ""
    
    override func viewWillAppear(_ animated: Bool) {
        newTime = setUpDatePicker(date: myDatePicker.date)
        originalTripTime = currentTrip?["LatestTime"] as! String
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        if let delegate = navigationController?.transitioningDelegate as? HalfModalTransitioningDelegate {
            delegate.interactiveDismiss = false
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func setUpDatePicker(date: Date) -> String {
        // Create date formatter
        let dateFormatter: DateFormatter = DateFormatter()
        
        // Set date format
        dateFormatter.dateFormat = "MMM d, h:mm a"
        
        // Apply date format
        let selectedDate: String = dateFormatter.string(from: date as Date)
        
        return selectedDate
    }
    
    @IBAction func changeTimeDatePickerAction(_ sender: Any) {
        newTime = setUpDatePicker(date: myDatePicker.date)
        print("new time = \(newTime)")
    }
    
    @IBAction func didTapChangeTime(_ sender: Any) {
        
        addUserToTrip(withNewTime: newTime) //change the time to the new user specified time
        
        if let delegate = navigationController?.transitioningDelegate as? HalfModalTransitioningDelegate {
            delegate.interactiveDismiss = false
        }
        dismiss(animated: true, completion: nil)
    }

    @IBAction func didTapLeaveTime(_ sender: Any) {
        
        addUserToTrip(withNewTime: originalTripTime) //keep the time as the original trip time
        
        if let delegate = navigationController?.transitioningDelegate as? HalfModalTransitioningDelegate {
            delegate.interactiveDismiss = false
        }
        dismiss(animated: true, completion: nil)
    }
    
    //====== ADD USER TO TRIP WHEN "REQUEST TO JOIN" (aka "Merge") IS PRESSED =======
    func addUserToTrip(withNewTime newTime: String) {
        var membersArray = currentTrip?["Members"] as! [PFUser]
        if membersArray.count < 4 {
            let memberNames = Helper.returnMemberNames(tripMembers: membersArray)
            if let fullname = PFUser.current()?["fullname"] {
                if memberNames.contains(fullname as! String) == false {
                    membersArray.append(PFUser.current()!)
                    currentTrip?["Members"] = membersArray
                    
                    //change the latest time of the trip
                    currentTrip?["LatestTime"] = newTime
                    
                    //SAVE this updated trip info to the trip
                    currentTrip?.saveInBackground(block: { (success: Bool, error: Error?) in
                        if let error = error {
                            print(error.localizedDescription)
                        } else if success{
                            print("😆success! updated trip to add new member")
                        }
                    })
                    currentTrip = nil
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
