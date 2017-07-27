//
//  Helper.swift
//  CarSharingApp
//
//  Created by Elan Halpern on 7/26/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import Foundation
import Parse

class Helper {
    
    /*
     * Deletes the trip from the user's list of trips
     * Deletes the trip from parse
     */
    static func deleteTrip(trip: PFObject) {
        
        trip.deleteInBackground(block: { (success: Bool, error: Error?) in
            if let error = error {
                print(error.localizedDescription)
            } else if success == true{
                print("trip deleted !")
            }
        })
    }
    
    static func dateToString(date: NSDate) -> String {
        // Create date formatter
        let dateFormatter: DateFormatter = DateFormatter()
        
        // Set date format
        dateFormatter.dateFormat = "MMM d, h:mm a"
        
        // Apply date format
        let selectedDate: String = dateFormatter.string(from: date as Date)
        return selectedDate
    }
    
    static func returnMemberNames(tripMembers: [PFUser]) -> [String] {
        var memberNames: [String] = []
        for member in tripMembers {
            if let memberName = member["fullname"] as? String {
                memberNames.append(memberName)
            }
        }
        return memberNames
    }
    
    static func  returnMemberProfPics(tripMembers: [PFUser]) -> [PFFile] {
        var memberPics: [PFFile] = []
        for member in tripMembers {
            print("HI")
            if let profPic = member["profPic"] as? PFFile {
                memberPics.append(profPic)
            }
        }
        return memberPics
    }

    //returnMemberProfPics
    //compareDates
    //isValidDateWindow
    //areValidLocations
    //isValidTripName
    //Look at all the ones in notifications vc
    
    
}
