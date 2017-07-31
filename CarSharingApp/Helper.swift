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
    
    static func teal() -> UIColor {
        return UIColor(red: 63.0/255.0, green: 150.0/255.0, blue: 203.0/255.0, alpha: 1.0)
    }
    
    static func navy() -> UIColor {
        return UIColor(red: 68.0/255.0, green: 105.0/255.0, blue: 171.0/255.0, alpha: 1.0)
    }
    
    static func coral() -> UIColor {
        return UIColor(red: 254.0/255.0, green: 104.0/255.0, blue: 106.0/255.0, alpha: 1.0)
    }
    
    static func veryLightGray() -> UIColor {
        return UIColor(red: 205.0/255.0, green: 205.0/255.0, blue: 205.0/255.0, alpha: 1.0)
    }
    
    /*
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
    
    /*
     * Deletes the current user from each trip that it was in
     * If the user was the only person in a trip, delete that trip
     * Deletes the current user from parse
     */
    static func deleteUser() {
        
        let currentUser = PFUser.current()
        let query = PFQuery(className: "Trip")
        query.includeKey("Name")
        query.includeKey("Members")
        query.whereKey("Members", equalTo: currentUser)
        query.findObjectsInBackground { (trips: [PFObject]?, error: Error?) in
            if let trips = trips {
                
                for trip in trips {
                    var memberList = trip["Members"] as! [PFUser] //get trip's list of members
                    let currentUserName = PFUser.current()?["fullname"] as! String
                    for member in memberList {
                        let memberName = member["fullname"] as! String
                        if memberName == currentUserName {
                            let removeIndex = memberList.index(of: member)
                            memberList.remove(at: removeIndex!)
                        }
                    }
                    
                    if memberList.count > 0 {
                        trip.saveInBackground(block: { (success: Bool, error: Error?) in
                            if let error = error {
                                print(error.localizedDescription)
                            } else if success == true{
                                print("FROM SETTINGS PAGE: trip saved so no longer has user")
                            }
                        })
                    }
                    else if memberList.count == 0 {
                        trip.deleteInBackground(block: { (success: Bool, error: Error?) in
                            if let error = error {
                                print(error.localizedDescription)
                            } else if success == true{
                                print("FROM SETTINGS PAGE: trip deleted")
                            }
                        })
                    }
                    
                }//close for loop
                
            }//close if let trip=trips
            
            PFUser.current()?.deleteInBackground(block: { (success: Bool, error: Error?) in
                if let error = error {
                    print(error.localizedDescription)
                } else if success == true{
                    print("user deleted !")
                }
            })
            
            //logs user out
            NotificationCenter.default.post(name: NSNotification.Name("logoutNotification"), object: nil)
            PFUser.logOutInBackground(block: { (error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("Successful loggout")
                }
            })
            
        }//close query
        
    }
    
    
    
    static func displayEmptyTableView(withTableView tableView: UITableView, withText text: String) {
        //no lines between table view cells
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.white
        let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
        noDataLabel.text = text
        noDataLabel.textColor = UIColor.black
        noDataLabel.font =  UIFont (name: "Quicksand", size: 20)
        noDataLabel.textAlignment = .center
        tableView.backgroundView  = noDataLabel
    }
    
    static func displayEmptyCollectionView(withCollectionView collectionView: UICollectionView, withText text: String) {
        //no lines between collection view cells
        collectionView.backgroundColor = Helper.veryLightGray()
        let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height))
        noDataLabel.text = text
        noDataLabel.textColor = UIColor.black
        noDataLabel.font =  UIFont (name: "Quicksand", size: 20)
        noDataLabel.textAlignment = .center
        collectionView.backgroundView  = noDataLabel
    }
    
    static func dateToString(date: NSDate) -> String {
        // Create date formatter
        let dateFormatter: DateFormatter = DateFormatter()
        
        // Set date format
        dateFormatter.dateFormat = "MMM d, YYYY h:mm a"        
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

    static func displayProfilePics(withCell cell: TripCell, withMemberPics pics: [PFFile]){
        let count = pics.count
        cell.onePersonImageView.isHidden = true
        cell.twoPeopleImageView1.isHidden = true
        cell.twoPeopleImageView2.isHidden = true
        cell.threePeopleImageView1.isHidden = true
        cell.threePeopleImageView2.isHidden = true
        cell.threePeopleImageView3.isHidden = true
        cell.fourPeopleImageView1.isHidden = true
        cell.fourPeopleImageView2.isHidden = true
        cell.fourPeopleImageView3.isHidden = true
        cell.fourPeopleImageView4.isHidden = true
        
        if(count == 1){
            cell.onePersonImageView.isHidden = false
            let profPic = pics[0]
            profPic.getDataInBackground(block: { (data: Data?, error: Error?) in
                cell.onePersonImageView.image = UIImage(data: data!)
            })
        } else if (count == 2) {
            let profPic1 = pics[0]
            let profPic2 = pics[1]
            profPic1.getDataInBackground(block: { (data: Data?, error: Error?) in
                cell.twoPeopleImageView1.image = UIImage(data: data!)
            })
            profPic2.getDataInBackground(block: { (data: Data?, error: Error?) in
                cell.twoPeopleImageView2.image = UIImage(data: data!)
            })
            cell.twoPeopleImageView1.isHidden = false
            cell.twoPeopleImageView2.isHidden = false
        } else if (count == 3) {
            let profPic1 = pics[0]
            let profPic2 = pics[1]
            let profPic3 = pics[2]
            cell.threePeopleImageView1.isHidden = false
            cell.threePeopleImageView2.isHidden = false
            cell.threePeopleImageView3.isHidden = false
            profPic1.getDataInBackground(block: { (data: Data?, error: Error?) in
                cell.threePeopleImageView1.image = UIImage(data: data!)
            })
            profPic2.getDataInBackground(block: { (data: Data?, error: Error?) in
                cell.threePeopleImageView2.image = UIImage(data: data!)
            })
            profPic3.getDataInBackground(block: { (data: Data?, error: Error?) in
                cell.threePeopleImageView3.image = UIImage(data: data!)
            })
        } else if (count == 4) {
            let profPic1 = pics[0]
            let profPic2 = pics[1]
            let profPic3 = pics[2]
            let profPic4 = pics[3]
            cell.fourPeopleImageView1.isHidden = false
            cell.fourPeopleImageView2.isHidden = false
            cell.fourPeopleImageView3.isHidden = false
            cell.fourPeopleImageView4.isHidden = false
            profPic1.getDataInBackground(block: { (data: Data?, error: Error?) in
                cell.fourPeopleImageView1.image = UIImage(data: data!)
            })
            profPic2.getDataInBackground(block: { (data: Data?, error: Error?) in
                cell.fourPeopleImageView2.image = UIImage(data: data!)
            })
            profPic3.getDataInBackground(block: { (data: Data?, error: Error?) in
                cell.fourPeopleImageView3.image = UIImage(data: data!)
            })
            profPic4.getDataInBackground(block: { (data: Data?, error: Error?) in
                cell.fourPeopleImageView4.image = UIImage(data: data!)
            })
        }
        
    }
    /*
     * Check if a trip is in the past by comparing it's latest date to the current date
     */
    static func isPastTrip(trip: PFObject) -> Bool {
        
        let datePickerView : UIDatePicker = UIDatePicker()
        let today = datePickerView.date as NSDate
        print(trip["LatestTime"] as! String)
        print(Helper.dateToString(date: today))
        let latestTime = trip["LatestTime"] as! String
        let lateDate = latestTime.stringToDate()
        if today.isGreaterThanDate(dateToCompare: lateDate) { //logic should be isless than but that was not working
            return true
        }
        return false
    }
    
    // Same thing, but for a collectionView
    
    static func displayProfilePics(withCell cell: messagesCell, withMemberPics pics: [PFFile]){
        let count = pics.count
        cell.onePersonImageView.isHidden = true
        cell.twoPeopleImageView1.isHidden = true
        cell.twoPeopleImageView2.isHidden = true
        cell.threePeopleImageView1.isHidden = true
        cell.threePeopleImageView2.isHidden = true
        cell.threePeopleImageView3.isHidden = true
        cell.fourPeopleImageView1.isHidden = true
        cell.fourPeopleImageView2.isHidden = true
        cell.fourPeopleImageView3.isHidden = true
        cell.fourPeopleImageView4.isHidden = true
        
        if(count == 1){
            cell.onePersonImageView.isHidden = false
            let profPic = pics[0]
            profPic.getDataInBackground(block: { (data: Data?, error: Error?) in
                cell.onePersonImageView.image = UIImage(data: data!)
            })
        } else if (count == 2) {
            let profPic1 = pics[0]
            let profPic2 = pics[1]
            profPic1.getDataInBackground(block: { (data: Data?, error: Error?) in
                cell.twoPeopleImageView1.image = UIImage(data: data!)
            })
            profPic2.getDataInBackground(block: { (data: Data?, error: Error?) in
                cell.twoPeopleImageView2.image = UIImage(data: data!)
            })
            cell.twoPeopleImageView1.isHidden = false
            cell.twoPeopleImageView2.isHidden = false
        } else if (count == 3) {
            let profPic1 = pics[0]
            let profPic2 = pics[1]
            let profPic3 = pics[2]
            cell.threePeopleImageView1.isHidden = false
            cell.threePeopleImageView2.isHidden = false
            cell.threePeopleImageView3.isHidden = false
            profPic1.getDataInBackground(block: { (data: Data?, error: Error?) in
                cell.threePeopleImageView1.image = UIImage(data: data!)
            })
            profPic2.getDataInBackground(block: { (data: Data?, error: Error?) in
                cell.threePeopleImageView2.image = UIImage(data: data!)
            })
            profPic3.getDataInBackground(block: { (data: Data?, error: Error?) in
                cell.threePeopleImageView3.image = UIImage(data: data!)
            })
        } else if (count == 4) {
            let profPic1 = pics[0]
            let profPic2 = pics[1]
            let profPic3 = pics[2]
            let profPic4 = pics[3]
            cell.fourPeopleImageView1.isHidden = false
            cell.fourPeopleImageView2.isHidden = false
            cell.fourPeopleImageView3.isHidden = false
            cell.fourPeopleImageView4.isHidden = false
            profPic1.getDataInBackground(block: { (data: Data?, error: Error?) in
                cell.fourPeopleImageView1.image = UIImage(data: data!)
            })
            profPic2.getDataInBackground(block: { (data: Data?, error: Error?) in
                cell.fourPeopleImageView2.image = UIImage(data: data!)
            })
            profPic3.getDataInBackground(block: { (data: Data?, error: Error?) in
                cell.fourPeopleImageView3.image = UIImage(data: data!)
            })
            profPic4.getDataInBackground(block: { (data: Data?, error: Error?) in
                cell.fourPeopleImageView4.image = UIImage(data: data!)
            })
        }
        
    }
    
}
