//
//  message.swift
//  CarSharingApp
//
//  Created by Chavane Minto on 7/18/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import UIKit
import Parse

class message: NSObject {
    
    class func postMessage(withMessageText messageText: String?, withAuthor author: String?, withDateSent dateSent: String?, withTripID TripID: String?, withCompletion completion: @escaping (PFObject?, Error?) -> ()) {
        
        if messageText == "" {
            
            print("no text")
            
        } else {
           
            let message = PFObject(className: "Message")
            
            message["Text"] = messageText
            message["Author"] = author
            message["dateSent"] = dateSent
            message["TripID"] = TripID
            
            message.saveInBackground { (success: Bool, error: Error?) in
                completion(message, error)
            }
            
        }
        
    }

}
