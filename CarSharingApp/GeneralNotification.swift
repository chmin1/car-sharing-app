//
//  GeneralNotification.swift
//  CarSharingApp
//
//  Created by Annabel Strauss on 8/1/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import Foundation
import Parse
import UIKit

class GeneralNotification: NSObject {
    
    class func postGeneralNotification(withTrip trip: PFObject?, withUserList userList: [PFUser?], withMessage message: String?, withCompletion completion: @escaping (PFObject?, Error?) -> ()) {
        
        // Create Request Object: PFObject
        let notif = PFObject(className: "GeneralNotification")
        
        //Add relevant fields to the object
        notif["Trip"] = trip
        notif["UserList"] = userList
        notif["Message"] = message
        
        // Save object (following function will save the object in Parse asynchronously)
        notif.saveInBackground { (success: Bool, error: Error?) in
            completion(notif, error)
        }
        
    }//close postRequest function
    
}//close Request class
