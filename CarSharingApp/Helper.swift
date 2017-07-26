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
    
    
}
