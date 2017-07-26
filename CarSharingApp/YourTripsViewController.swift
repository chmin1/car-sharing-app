//
//  YourTripsViewController.swift
//  CarSharingApp
//
//  Created by Annabel Strauss on 7/13/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import UIKit
import Parse

class YourTripsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var yourTrips: [PFObject] = []
    var refreshControl: UIRefreshControl!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var yourTripsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Initialize a Refresh Control
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        // add refresh control to table view
        yourTripsTableView.insertSubview(refreshControl, at: 0)
        
        refresh()
        
        yourTripsTableView.dataSource = self
        yourTripsTableView.delegate = self
        
    }
    
    //====== PULL TO REFRESH =======
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        refresh()
    }
    
    func refresh() {
        activityIndicator.startAnimating()
        let currentUser = PFUser.current()
        let query = PFQuery(className: "Trip")
        query.includeKey("Name")
        query.includeKey("Members")
        query.whereKey("Members", equalTo: currentUser)
        query.findObjectsInBackground { (trips: [PFObject]?, error: Error?) in
            if let trips = trips {
                self.yourTrips.removeAll()
                for trip in trips {
                    if let tripEditId = trip["EditID"] as? String { //get EditID so that the trip won't show if it's an edit
                        if(tripEditId != "-1"){ //only add trip to the feed if it's NOT an edit
                            self.yourTrips.append(trip)
                            self.yourTripsTableView.reloadData()
                            self.refreshControl.endRefreshing()
                            self.activityIndicator.stopAnimating()
                        } else {
                            print(error?.localizedDescription)
                        }
                    }
                    
                }
            }
        }
    }
    
    /*
     * Sets up the cells
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripCell", for: indexPath) as! TripCell
        let trip = yourTrips[indexPath.row]
        let tripName = trip["Name"] as! String
        
        let departureLocation = trip["DepartureLoc"] as! String
        let arrivalLocation = trip["ArrivalLoc"] as! String
        let earliestDepart = trip["EarliestTime"] as! String
        let latestDepart = trip["LatestTime"] as! String
        print("depart: \(departureLocation)")
        print("arriv: \(arrivalLocation)")
        print("earliestdep: \(earliestDepart)")
        print("latestdep: \(latestDepart)")
        if let tripMembers = trip["Members"] as? [PFUser] {
            print(tripName)
            let memberNames = returnMemberNames(tripMembers: tripMembers)
            print(memberNames)
            var memberString = ""
            
            for memberName in memberNames {
                memberString += memberName
                if memberName != memberNames.last {
                    memberString += ", "
                }
            }
            cell.tripMembersLabel.text = memberString
            
            let memberProfPics = returnMemberProfPics(tripMembers: tripMembers)
            displayProfilePics(withCell: cell, withMemberPics: memberProfPics)
        }
        
        cell.tripName.text = tripName
        cell.departLabel.text = departureLocation
        cell.destinationLabel.text = arrivalLocation
        cell.earlyTimeLabel.text = earliestDepart
        cell.lateDepartLabel.text = latestDepart
        return cell
    }
    
    func displayProfilePics(withCell cell: TripCell, withMemberPics pics: [PFFile]){
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
    
    //======== TURNS ARRAY OF MEMBERS' PROF PICS ========
    func returnMemberProfPics(tripMembers: [PFUser]) -> [PFFile] {
        var memberPics: [PFFile] = []
        for member in tripMembers {
            print("HI")
            if let profPic = member["profPic"] as? PFFile {
                memberPics.append(profPic)
            }
        }
        return memberPics
    }
    
    
    /*
     * Tells the tableview how many rows should be in each section
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return yourTrips.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //======== TURNS ARRAY OF MEMBERS FROM PFUSER TO STRING ========
    func returnMemberNames(tripMembers: [PFUser]) -> [String] {
        var memberNames: [String] = []
        for member in tripMembers {
            if let memberName = member["fullname"] as? String {
                memberNames.append(memberName)
            }
        }
        return memberNames
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //====== SEGUE TO DETAIL VIEW =======
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        if let indexPath = yourTripsTableView.indexPath(for: cell) {//get this to find the actual trip
            let trip = yourTrips[indexPath.row] //get the trip
            let detailViewController = segue.destination as! TripDetailViewController //tell it its destination
            detailViewController.trip = trip
        }
    }
    
}
