
//  ProfileViewController.swift
//  CarSharingApp
//
//  Created by Elan Halpern on 7/19/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import UIKit
import Parse

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource { //UITableViewDataSource {
    
    @IBOutlet weak var profileButton: UIBarButtonItem!
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tripsTableView: UITableView!
    var newProfPic: UIImage?
    @IBOutlet weak var mySegmentedControl: UISegmentedControl!
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
        
        //for hamburger menu
        if self.revealViewController() != nil {
            profileButton.target = self.revealViewController()
            profileButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        if user == nil {
            user = PFUser.current()
        }
        
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
        let currentUser = PFUser.current()
        let query = PFQuery(className: "Trip")
        query.includeKey("Name")
        query.includeKey("Members")
        query.whereKey("Members", equalTo: currentUser)
        query.findObjectsInBackground { (trips: [PFObject]?, error: Error?) in
            if let trips = trips {
                self.currentTrips.removeAll()
                self.pastTrips.removeAll()
                for trip in trips {
                    if let tripEditId = trip["EditID"] as? String { //get EditID so that the trip won't show if it's an edit
                        if(tripEditId != "-1" && !Helper.isPastTrip(trip: trip)){ //only add trip to the feed if it's NOT an edit
                            self.currentTrips.append(trip)
                        } else if(tripEditId != "-1" && Helper.isPastTrip(trip: trip)){
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
    
    @IBAction func didTapProfilePic(_ sender: Any) {
        choosePhoto()
    }
    
    /*
     * This is the delegate method for image picker for choosing a prof pic
     * This calls the method to get the new pic and then SAVES in background
     */
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        // Get the image captured by the UIImagePickerController
        let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        // Do something with the images (based on your use case)
        newProfPic = editedImage
        
        //uploads the new prof pic to the cloud
        let portrait = User.getPFFileFromImage(image: newProfPic)
        PFUser.current()?["profPic"] = portrait
        PFUser.current()?.saveInBackground()
        
        // Dismiss UIImagePickerController to go back to your original view controller
        dismiss(animated: true, completion: nil)
    }
    
    /*
     * This is also for choosing a prof pic
     */
    func choosePhoto() {
        // Instantiate a UIImagePickerController
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        
        //allow user to pick between photo library or camera
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {
            action in
            vc.sourceType = .camera
            self.present(vc, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {
            action in
            vc.sourceType = .photoLibrary
            self.present(vc, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        //Present the camera or photo library depending on what the user picked
        self.present(alert, animated: true, completion: nil)
    }//close choosePhoto
    
    
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
                var memberString = ""
                
                for memberName in memberNames {
                    memberString += memberName.capitalized
                    if memberName != memberNames.last {
                        memberString += ", "
                    }
                }
                myCell.tripMembersLabel.text = memberString
                
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
                var memberString = ""
                
                for memberName in memberNames {
                    memberString += memberName.capitalized
                    if memberName != memberNames.last {
                        memberString += ", "
                    }
                }
                myCell.tripMembersLabel.text = memberString
                
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
