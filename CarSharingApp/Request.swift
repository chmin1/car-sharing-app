//
//  Request.swift
//  CarSharingApp
//
//  Created by Annabel Strauss on 7/31/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import Foundation
import Parse
import UIKit


class Request: NSObject {
    
    class func postRequest(withTrip trip: PFObject?, withUser user: PFUser?, withTime newTime: NSDate, withCompletion completion: @escaping (PFObject?, Error?) -> ()) {
        
        // Create Request Object: PFObject
        let request = PFObject(className: "Request")
        
        //Add relevant fields to the object
        request["Trip"] = trip
        request["User"] = user
        request["NewTime"] = newTime
        let planner = trip?["Planner"] as! PFUser
        request["TripPlannerID"] = planner.objectId
        request["UserID"] = user?.objectId
        
        // Save object (following function will save the object in Parse asynchronously)
        request.saveInBackground { (success: Bool, error: Error?) in
            completion(request, error)
        }
        
    }//close postRequest function
    
}//close Request class
