//
//  College.swift
//  CarSharingApp
//
//  Created by Chavane Minto on 7/12/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import Foundation

class College {
    
    var alphaCode: String
    var country: String
    var domain: String
    var name: String
    
    class func colleges(dictionaries: [[String: Any]]) -> [College] {
        var colleges: [College] = []
        for dictionary in dictionaries {
            let college = College(dictionary: dictionary)
            colleges.append(college)
        }
        
        return colleges
    }
    
    init(dictionary: [String: Any]) {
        
        alphaCode = dictionary["alpha_two_code"] as! String
        country = dictionary["country"] as! String
        domain = dictionary["domain"] as! String
        name = dictionary["name"] as! String
        
    }
    
}
