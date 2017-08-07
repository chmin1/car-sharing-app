//
//  UserProfileViewController.swift
//  CarSharingApp
//
//  Created by Annabel Strauss on 7/31/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import UIKit
import Parse

class UserProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mySegmentedControl: UISegmentedControl!
    @IBOutlet weak var tripsTableView: UITableView!
    var user: PFUser!
    var currentTrips: [PFObject] = []
    var pastTrips: [PFObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //make bar button items in nav bar white
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        tripsTableView.delegate = self
        tripsTableView.dataSource = self
        refresh()
        
        //make prof pic circular
        profilePicImageView.layer.cornerRadius = profilePicImageView.frame.size.width / 2
        profilePicImageView.clipsToBounds = true
        
        
        //set name label
        let nameText = user["fullname"] as! String
        nameLabel.text = nameText.capitalized
        
        //set background and text color of Nav bar
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = Helper.coral()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        //change color of segmented control
        mySegmentedControl.tintColor = Helper.peach()
        
    }
    
    func refresh() {
        //activityIndicator.startAnimating()
        let query = PFQuery(className: "Trip")
        query.includeKey("Name")
        query.includeKey("Members")
        query.whereKey("Members", equalTo: user!) //BUGGY I THINK
        query.findObjectsInBackground { (trips: [PFObject]?, error: Error?) in
            if let trips = trips {
                self.currentTrips.removeAll()
                self.pastTrips.removeAll()
                for trip in trips {
                    if let tripEditId = trip["EditID"] as? String { //get EditID so that the trip won't show if it's an edit
                        if(tripEditId != "-1" && !Helper.isPastTrip(trip: trip)){ //only add trip to the feed if it's NOT an edit
                            self.currentTrips.append(trip)
                        } else if(tripEditId != "-1" && Helper.isPastTrip(trip: trip)) {
                            self.pastTrips.append(trip)
                            
                        } else {
                            print(error?.localizedDescription)
                        }
                    }
                    
                }
                //displays the "No trips" label if there are no trips to display
                /*
                 if self.yourTrips.count == 0 {
                 Helper.displayEmptyTableView(withTableView: self.yourTripsTableView, withText: "You are not currently in any trips!")
                 self.emojiView.isHidden = false
                 }
                 */
                
                
                self.tripsTableView.reloadData()
                //self.refreshControl.endRefreshing()
                //self.activityIndicator.stopAnimating()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //set prof pic
        if let profPic = user["profPic"] as? PFFile {
            profPic.getDataInBackground { (imageData: Data!, error: Error?) in
                self.profilePicImageView.image = UIImage(data: imageData)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var returnVal = 0
        switch(mySegmentedControl.selectedSegmentIndex)
        {
        case 0:
            returnVal = currentTrips.count
            break
        case 1:
            returnVal = pastTrips.count
            break
        default:
            break
        }
        
        return returnVal
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myCell = tripsTableView.dequeueReusableCell(withIdentifier: "TripCell", for: indexPath) as! TripCell
        
        switch(mySegmentedControl.selectedSegmentIndex)
        {
        case 0:
            let trip = currentTrips[indexPath.row]
            let tripName = trip["Name"] as! String
            
            let departureLocation = trip["DepartureLoc"] as! String
            let arrivalLocation = trip["ArrivalLoc"] as! String
            let earlyDate = trip["EarliestDate"] as! NSDate
            let lateDate = trip["LatestDate"] as! NSDate
            
            let earlyStr = Helper.dateToString(date: earlyDate)
            let lateStr = Helper.dateToString(date: lateDate)
            
            if let tripMembers = trip["Members"] as? [PFUser] {
                print(tripName)
                let memberNames = Helper.returnMemberNames(tripMembers: tripMembers)
                print(memberNames)
                
                let memberProfPics = Helper.returnMemberProfPics(tripMembers: tripMembers)
                Helper.displayProfilePics(withCell: myCell, withMemberPics: memberProfPics)
            }
            
            
            myCell.tripName.text = tripName.capitalized
            myCell.departLabel.text = departureLocation
            myCell.destinationLabel.text = arrivalLocation
            myCell.earlyTimeLabel.text = earlyStr
            myCell.lateDepartLabel.text = lateStr
            break
        case 1:
            let trip = pastTrips[indexPath.row]
            let tripName = trip["Name"] as! String
            
            let departureLocation = trip["DepartureLoc"] as! String
            let arrivalLocation = trip["ArrivalLoc"] as! String
            let earlyDate = trip["EarliestDate"] as! NSDate
            let lateDate = trip["LatestDate"] as! NSDate
            
            let earlyStr = Helper.dateToString(date: earlyDate)
            let lateStr = Helper.dateToString(date: lateDate)

            if let tripMembers = trip["Members"] as? [PFUser] {
                print(tripName)
                let memberNames = Helper.returnMemberNames(tripMembers: tripMembers)
                print(memberNames)
                
                let memberProfPics = Helper.returnMemberProfPics(tripMembers: tripMembers)
                Helper.displayProfilePics(withCell: myCell, withMemberPics: memberProfPics)
            }
            
            
            myCell.tripName.text = tripName.capitalized
            myCell.departLabel.text = departureLocation
            myCell.destinationLabel.text = arrivalLocation
            myCell.earlyTimeLabel.text = earlyStr
            myCell.lateDepartLabel.text = lateStr
            break
        default:
            break
        }
        
        return myCell
    }
    
    //TOGGLING SEGMENTED CONTROL
    @IBAction func segmentedControlActionChanged(_ sender: Any) {
        tripsTableView.reloadData()
    }
    
    //====== SEGUE TO DETAIL VIEW =======
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        if let indexPath = tripsTableView.indexPath(for: cell) {//get this to find the actual trip
            switch(mySegmentedControl.selectedSegmentIndex)
            {
            case 0:
                let trip = currentTrips[indexPath.row] //get the trip
                let detailViewController = segue.destination as! TripDetailViewController //tell it its destination
                detailViewController.trip = trip
                break
            case 1:
                let trip = pastTrips[indexPath.row] //get the trip
                let detailViewController = segue.destination as! TripDetailViewController //tell it its destination
                detailViewController.trip = trip
                break
            default:
                break
            }
        }
    }
    
    
    
}
