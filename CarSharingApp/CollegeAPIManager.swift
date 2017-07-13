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
    //static let collegeUrl = "https://raw.githubusercontent.com/Hipo/university-domains-list/master/world_universities_and_domains.json"
    
    var session: URLSession
    var domain: String
    
    init() {
        session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        domain = ""
    }
    
    func getDomainFromApi(school: String?, completion: @escaping (String?, Error?) -> ()) {
        
        guard let school = school else {
            // handle case when school is nil
            return
        }
        
        let collegeUrl = URL(string: "http://universities.hipolabs.com/search?name=\(school)")
        let request = URLRequest(url: collegeUrl!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if let data = data {
                
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [[String: Any]]
                //let collegeDictionaries = dataDictionary[""] as! [[String: Any]]
                
                let colleges = College.colleges(dictionaries: dataDictionary)
                
                let college = colleges[0]
                //self.domain = college.domain
                //print(domain)
                
                completion(college.domain, nil)
                
            } else {
                completion(nil, error)
            }
            
        }
        
        task.resume()
        
    }
    
//    // MARK: TODO: Get User Timeline (profile page)
//    func getSchool(_ school: String, completion: @escaping ([College]?, Error?) -> ()) {
//        
//        let urlString = "http://universities.hipolabs.com/search?name=\(school)"
//        
//        request(urlString, method: .get)
//            .validate()
//            .responseJSON { (response) in
//                guard response.result.isSuccess else {
//                    completion(nil, response.result.error)
//                    return
//                }
//                guard let collegeDictionaries = response.result.value as? [[String: Any]] else {
//                    print("Failed to parse schools")
//                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Failed to parse schools"])
//                    completion(nil, error)
//                    return
//                }
//                
//                let data = NSKeyedArchiver.archivedData(withRootObject: tweetDictionaries)
//                UserDefaults.standard.set(data, forKey: "hometimeline_tweets")
//                UserDefaults.standard.synchronize()
//                
//                let tweets = tweetDictionaries.flatMap({ (dictionary) -> Tweet in
//                    Tweet(dictionary: dictionary)
//                })
//                completion(tweets, nil)
//        }
//    }//close getUserTweets
    
}
