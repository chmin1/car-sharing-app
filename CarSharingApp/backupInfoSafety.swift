//
//  backupInfoSafety.swift
//  CarSharingApp
//
//  Created by Annabel Strauss on 7/13/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import Foundation


//put this in the sign up view controller page to get the API domain based on the school that the user put in on sign up
//CollegeAPIManager.init().getDomainFromApi(school: collegeTextField.text, completion: { (domain, error) in
//    if let domain = domain{
//        print("API domain: \(domain)")
//    } else if let error = error {
//        print("Error getting home timeline: " + error.localizedDescription)
//    }
//})


//put this in College class for API use
//class College {
//    
//    var alphaCode: String
//    var country: String
//    var domain: String
//    var name: String
//    
//    class func colleges(dictionaries: [[String: Any]]) -> [College] {
//        var colleges: [College] = []
//        for dictionary in dictionaries {
//            let college = College(dictionary: dictionary)
//            colleges.append(college)
//        }
//        
//        return colleges
//    }
//    
//    init(dictionary: [String: Any]) {
//        
//        alphaCode = dictionary["alpha_two_code"] as! String
//        country = dictionary["country"] as! String
//        domain = dictionary["domain"] as! String
//        name = dictionary["name"] as! String
//        
//    }
//    
//}

//====== TURNS A DATE STRING TO NSDATE =======
//func stringToDate(dateString: String) -> NSDate {
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "MMM d, h:mm a"
//    
//    let dateObj = dateFormatter.date(from: dateString)
//    
//    return dateObj! as NSDate //sketchy
//}
//
