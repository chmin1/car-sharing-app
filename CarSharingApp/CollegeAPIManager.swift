//
//  CollegeAPIManager.swift
//  CarSharingApp
//
//  Created by Chavane Minto on 7/12/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import Foundation

class CollegeAPIManager {
    
    // URL that holds info on all colleges
    static let collegeUrl = "https://raw.githubusercontent.com/Hipo/university-domains-list/master/world_universities_and_domains.json"
    
    var session: URLSession
    
    init() {
        session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
    }
    
    func verifiedColleges(completion: @escaping ([College]?, Error?) -> ()) {
        
        let request = URLRequest(url: URL(string: CollegeAPIManager.collegeUrl)!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if let data = data {
                
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let collegeDictionaries = dataDictionary[""] as! [[String: Any]]
                
                let colleges = College.colleges(dictionaries: collegeDictionaries)
                completion(colleges, nil)
                
            } else {
                
                completion(nil, error)
                
            }
            
        }
        
        task.resume()
        
    }
    
}
