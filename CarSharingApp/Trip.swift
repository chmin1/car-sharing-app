//
//  Trip.swift
//  CarSharingApp
//
//  Created by Chavane Minto on 7/12/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import UIKit
import Parse


class Trip: NSObject {
    

    
    // Method to upload user trip to Parse
    
    /*
     
     Parameters:
        - User can add Departure Location (From)
        - User can add Arrival location (To)
        - User can add the Earliest & Latest times of departure
     
    */
    
    class func postTrip(withName tripName: String?, withDeparture departureLoc: String?, withArrival arrivalLoc: String?, withEarliest earlyDepart: NSDate?, withLatest lateDepart: NSDate?, withCompletion completion: PFBooleanResultBlock?) {
        
        
        
        // Create Trip Object: PFObject
        let trip = PFObject(className: "Trip")
        
        //Add relevant fields to the object
        trip["Name"] = tripName
        trip["Planner"] = PFUser.current()
        trip["DepartureLoc"] = departureLoc // Location where you will leave from
        trip["ArrivalLoc"] = arrivalLoc // Location you will arrive to
        trip["EarliestTime"] = earlyDepart // Earliest time you can leave
        trip["LatestTime"] = lateDepart // Latest timne you can leave
        
        
        
        // Save object (following function will save the object in Parse asynchronously)
        trip.saveInBackground { (success: Bool, error: Error?) in
            completion?(success, error)
        }
        
        
        
    }

}
