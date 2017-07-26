//
//  HomeViewController.swift
//  CarSharingApp
//
//  Created by Elan Halpern on 7/12/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import UIKit
import GooglePlaces
import Parse

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GMSAutocompleteViewControllerDelegate, HomeHeaderCellDelegate, CreateViewControllerDelegate {
    
    var locationSource: UILabel!
    var autoCompleteViewController: GMSAutocompleteViewController!
    var filter: GMSAutocompleteFilter!
    var HomeHeaderCell: HomeHeaderCell!
    var requestToJoinAlert: UIAlertController!
    var refreshControl: UIRefreshControl!
    var tripsFeed: [PFObject] = []
    //for when the user searches
    var filteredTripsFeed: [PFObject] = []
    var currentTrip: PFObject? 
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var profileButton: UIBarButtonItem!
    @IBOutlet weak var tripsTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        //for hamburger menu
        if self.revealViewController() != nil {
            profileButton.target = self.revealViewController()
            profileButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        //set up request to join alert
        setUpRequestToJoinAlert()
        
        //Set Up Table View
        tripsTableView.delegate = self
        tripsTableView.dataSource = self
        
        //get data from server
        refresh()
        
        //Set Up Autocomplete View controller
        filter = GMSAutocompleteFilter()
        filter.type = .address
        autoCompleteViewController = GMSAutocompleteViewController()
        autoCompleteViewController.delegate = self
        autoCompleteViewController.autocompleteFilter = filter
        
        //Initialize a Refresh Control
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        // add refresh control to table view
        tripsTableView.insertSubview(refreshControl, at: 0)
        
        
        
    }
    
    func tabBarController(tabbar: UITabBarController, didSelect: UIViewController) {
        print("HI")
        var secondTab = self.tabBarController?.viewControllers?[1] as? CreateViewController
        secondTab?.delegate = self
        
    }
    
    //TODO: Edit so that it changes what appears depending on the search parameters -- didn't we do this? 
    func refresh() {
        activityIndicator.startAnimating()
        let query = PFQuery(className: "Trip")
        query.includeKey("Planner")
        query.includeKey("Members")
        query.order(byDescending: "_created_at")
        query.findObjectsInBackground { (trips: [PFObject]?, error: Error?) in
            if let trips = trips {
                // do something with the array of object returned by the call
                self.tripsFeed.removeAll()
                self.filteredTripsFeed.removeAll()
                for trip in trips {
                    if let tripEditId = trip["EditID"] as? String { //get EditID so that the trip won't show if it's an edit
                        if(tripEditId != "-1"){ //only add trip to the feed if it's NOT an edit
                            self.tripsFeed.append(trip)
                            self.filteredTripsFeed.append(trip)
                        }
                    }
                }
                
                self.tripsTableView.reloadData()
                self.refreshControl.endRefreshing()
                self.activityIndicator.stopAnimating()
            } else {
                print(error?.localizedDescription)
            }
            
        }
    }
    
    //====== PULL TO REFRESH =======
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        refresh()
    }
    
    /*
     * Sets up the cells
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //sets up the headercell
        if indexPath.section == 0 {
            let headerCell = tableView.dequeueReusableCell(withIdentifier: "HomeHeaderCell") as! HomeHeaderCell
            headerCell.delegate = self
            HomeHeaderCell = headerCell
            return headerCell
        }
        //sets up all the other cells (the trip feed)
        else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TripCell", for: indexPath) as! TripCell
            cell.requestButton.isHidden = false //restore default aka request button shows
            let trip = filteredTripsFeed[indexPath.row]
            let tripName = trip["Name"] as! String
            
            let departureLocation = trip["DepartureLoc"] as! String
            let arrivalLocation = trip["ArrivalLoc"] as! String
            let earliestDepart = trip["EarliestTime"] as! String
            let latestDepart = trip["LatestTime"] as! String
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
                
                
                //hide the "request to join" button if the current user is already in that trip OR if that trip already has 4 ppl in it
                let currentMemberName = PFUser.current()?["fullname"] as! String
                if memberNames.contains(currentMemberName) || memberNames.count == 4 {
                    cell.requestButton.isHidden = true
                }
                
            }
            
            cell.tripName.text = tripName
            cell.departLabel.text = departureLocation
            cell.destinationLabel.text = arrivalLocation
            cell.earlyTimeLabel.text = earliestDepart
            cell.lateDepartLabel.text = latestDepart
            return cell
        }
        
        return UITableViewCell()
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
        } else if (count == 2) {
            cell.twoPeopleImageView1.isHidden = false
            cell.twoPeopleImageView2.isHidden = false
        } else if (count == 3) {
            cell.threePeopleImageView1.isHidden = false
            cell.threePeopleImageView2.isHidden = false
            cell.threePeopleImageView3.isHidden = false
        } else if (count == 4) {
            cell.fourPeopleImageView1.isHidden = false
            cell.fourPeopleImageView2.isHidden = false
            cell.fourPeopleImageView3.isHidden = false
            cell.fourPeopleImageView4.isHidden = false
        }
        
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
     * Determines the height of the sections
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 0) {
            return 200
        } else if (indexPath.section == 1) {
            return 160
        }
        return 0
    }
    
    /*
     * We have 2 sections becasue one is the "header" and one is the list of trips
     */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2;
    }
    
    
    
    /*
     * Tells the tableview how many rows should be in each section
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //secion 0 has 1 row (header)
        if (section == 0) {
            return 1
        }
            //section 1 has filteredTripsFeed.count rows
        else if (section == 1) {
            
            return filteredTripsFeed.count
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    

    
    func HomeHeaderCell(_ homeHeaderCell: HomeHeaderCell, didTap label: UILabel) {
        self.present(autoCompleteViewController, animated: true, completion: nil)
        if(label == HomeHeaderCell.startTextLabel) {
            locationSource = HomeHeaderCell.startTextLabel
        } else if(label == HomeHeaderCell.endTextLabel) {
            locationSource = HomeHeaderCell.endTextLabel
        }
        
    }
    
    /**
     * Called when a place has been selected from the available autocomplete predictions.
     *
     * Implementations of this method should dismiss the view controller as the view controller will not
     * dismiss itself.
     *
     * @param viewController The |GMSAutocompleteViewController| that generated the event.
     * @param place The |GMSPlace| that was returned.
     */
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        if locationSource == HomeHeaderCell.startTextLabel {
            HomeHeaderCell.startTextLabel.textColor = UIColor.black
            HomeHeaderCell.startTextLabel.text = place.formattedAddress
            print(HomeHeaderCell.startTextLabel.text!)
        } else if locationSource == HomeHeaderCell.endTextLabel {
            HomeHeaderCell.endTextLabel.textColor = UIColor.black
            HomeHeaderCell.endTextLabel.text = place.formattedAddress
        }
        self.dismiss(animated: true)
        
    }
    
    
    /**
     * Called when a non-retryable error occurred when retrieving autocomplete predictions or place
     * details.
     *
     * A non-retryable error is defined as one that is unlikely to be fixed by immediately retrying the
     * operation.
     *
     * Only the following values of |GMSPlacesErrorCode| are retryable:
     * <ul>
     * <li>kGMSPlacesNetworkError
     * <li>kGMSPlacesServerError
     * <li>kGMSPlacesInternalError
     * </ul>
     * All other error codes are non-retryable.
     *
     * @param viewController The |GMSAutocompleteViewController| that generated the event.
     * @param error The |NSError| that was returned.
     */
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print(error.localizedDescription)
        
    }
    
    
    /**
     * Called when the user taps the Cancel button in a |GMSAutocompleteViewController|.
     *
     * Implementations of this method should dismiss the view controller as the view controller will not
     * dismiss itself.
     *
     * @param viewController The |GMSAutocompleteViewController| that generated the event.
     */
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.tripsTableView.reloadData()
        dismiss(animated: true)
    }
    
    
    func didPostTrip(trip: PFObject) {
        print("did post trip")
        filteredTripsFeed.insert(trip, at: 0)
        tripsTableView.reloadData()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapRequestToJoin(_ sender: AnyObject) {
        if let cell = sender.superview??.superview as? TripCell {
            let indexPath = tripsTableView.indexPath(for: cell)
            currentTrip = filteredTripsFeed[(indexPath?.row)!]
        }
        
        present(requestToJoinAlert, animated: true, completion: nil)
    }
    
    func setUpRequestToJoinAlert(){
        // Set up the requestToJoinAlert
        requestToJoinAlert = UIAlertController(title: "Requesting To Join Trip", message: "Are you sure you want to join this trip?", preferredStyle: .alert)
        
        let noAction = UIAlertAction(title: "No", style: .cancel) { (action) in
            // handle cancel response here. Doing nothing will dismiss the view.
        }
        
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            self.addUserToTrip()
        }
        
        requestToJoinAlert.addAction(noAction) // add the no action to the alertController
        requestToJoinAlert.addAction(yesAction) // add the yes action to the alertController
    }
    
    //====== ADD USER TO TRIP WHEN "REQUEST TO JOIN" IS PRESSED =======
    func addUserToTrip() {
        var membersArray = currentTrip?["Members"] as! [PFUser]
        if membersArray.count < 4 {
            let memberNames = returnMemberNames(tripMembers: membersArray)
            if let fullname = PFUser.current()?["fullname"] {
                if memberNames.contains(fullname as! String) == false {
                    membersArray.append(PFUser.current()!)
                    currentTrip?["Members"] = membersArray
                    
                    //TODO: union operation on the times to change the trip time window
                    
                    //SAVE this updated trip info to the trip
                    currentTrip?.saveInBackground(block: { (success: Bool, error: Error?) in
                        if let error = error {
                            print(error.localizedDescription)
                        } else if success{
                            print("😆success! updated trip to add new member")
                            self.tripsTableView.reloadData()
                        }
                    })
                    currentTrip = nil
                } else if memberNames.contains(fullname as! String) == true{
                    print("You are already in this trip")
                }
            }
        }
        else {
            print("Can't join - this trip is already full")
        }
    }//close addUserToTrip()
    
    //====== SEGUE TO DETAIL VIEW =======
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "homeToDetail" {
            let cell = sender as! UITableViewCell
            if let indexPath = tripsTableView.indexPath(for: cell) {//get this to find the actual trip
                let trip = filteredTripsFeed[indexPath.row] //get the trip
                let detailViewController = segue.destination as! TripDetailViewController //tell it its destination
                detailViewController.trip = trip
            }
        }
    }
    
    @IBAction func didTapGo(_ sender: Any) {
        let departure = HomeHeaderCell.startTextLabel.text!
        let arrival = HomeHeaderCell.endTextLabel.text!
        let earliest = HomeHeaderCell.earliestTextField.text!
        let latest = HomeHeaderCell.latestTextField.text!
        
        let earliestDate = earliest.stringToDate()
        let latestDate = latest.stringToDate()
        
        filterContent(withDepartureText: departure, withArrivalText: arrival, withEarliestDate: earliestDate, withLatestDate: latestDate)
    }
    
    func filterContent(withDepartureText departureText: String, withArrivalText arrivalText: String, withEarliestDate earliestDate: NSDate, withLatestDate latestDate: NSDate) {
        
        filteredTripsFeed = tripsFeed.filter { trip in
            print(trip)
            let tripDeparture = trip["DepartureLoc"] as! String
            let tripArrival = trip["ArrivalLoc"] as! String
            let tripEarliest = trip["EarliestTime"] as! String
            let tripLatest = trip["LatestTime"] as! String
            let tripEarliestDate = tripEarliest.stringToDate()
            let tripLatestDate = tripLatest.stringToDate()
            
            return tripDeparture.lowercased() == departureText.lowercased() && tripArrival.lowercased() == arrivalText.lowercased() && compareDates(earliestDate: earliestDate, latestDate: latestDate, tripEarliestDate: tripEarliestDate, tripLatestDate: tripLatestDate)
        }
        tripsTableView.reloadData()
    }
    
    func compareDates(earliestDate: NSDate, latestDate: NSDate, tripEarliestDate: NSDate, tripLatestDate: NSDate) -> Bool {
        if ((earliestDate.isLessThanDate(dateToCompare: tripLatestDate) || earliestDate.equalToDate(dateToCompare: tripLatestDate)) &&
            (earliestDate.isGreaterThanDate(dateToCompare: tripEarliestDate) || earliestDate.equalToDate(dateToCompare: tripEarliestDate))) ||
            ((latestDate.isLessThanDate(dateToCompare: tripLatestDate) || latestDate.equalToDate(dateToCompare: tripLatestDate)) &&
            (latestDate.isGreaterThanDate(dateToCompare: tripEarliestDate) || latestDate.equalToDate(dateToCompare: tripEarliestDate))) {
            return true
        } else {
            return false
        }
    }
    


    
    
}
