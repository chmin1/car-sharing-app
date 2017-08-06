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
import GooglePlacePicker

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GMSPlacePickerViewControllerDelegate, HomeHeaderCellDelegate, CreateViewControllerDelegate {
    
    var locationSource: UILabel!
    var HomeHeaderCell: HomeHeaderCell!
    var refreshControl: UIRefreshControl!
    var tripsFeed: [PFObject] = []
    var emptyFieldAlert: UIAlertController!
    //for when the user searches
    var filteredTripsFeed: [PFObject] = []
    var currentTrip: PFObject?
    var requestedTrips: [String] = []
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var profileButton: UIBarButtonItem!
    @IBOutlet weak var tripsTableView: UITableView!
    
    @IBOutlet weak var emojiView: UIImageView!
    var halfModalTransitioningDelegate: HalfModalTransitioningDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up the emptyFieldAlert
        emptyFieldAlert = UIAlertController(title: "Empty Field", message: "Fill in all search fields!", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
            // handle cancel response here. Doing nothing will dismiss the view.
        }
        emptyFieldAlert.addAction(cancelAction) // add the cancel action to the alertController
        
        //make bar button items in nav bar white
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        //Set profile button to have profile picture of user
        //setProfilePicButton()
        
        
        //for hamburger menu
        if self.revealViewController() != nil {
            profileButton.target = self.revealViewController()
            profileButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        //Set Up Table View
        tripsTableView.delegate = self
        tripsTableView.dataSource = self
        
        //get data from server
        getUserRequests()
  
        //Initialize a Refresh Control
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        // add refresh control to table view
        tripsTableView.insertSubview(refreshControl, at: 0)
        
        //set width of the hamburger menu thing when it comes out
        self.revealViewController().rearViewRevealWidth = 200
        
        //set background and text color of Nav bar
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = Helper.coral()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        emojiView.isHidden = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        emojiView.isHidden = true
        getUserRequests()
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tabBarController(tabbar: UITabBarController, didSelect: UIViewController) {
        print("HI")
        let secondTab = self.tabBarController?.viewControllers?[1] as? CreateViewController
        secondTab?.delegate = self
        
    }
    
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
                        print(trip["Name"])
                        if(tripEditId != "-1") && !Helper.isPastTrip(trip: trip) && Helper.isSameSchool(withTrip: trip){ //only add trip to the feed if it's NOT an edit and not in the past and the same school as the current user 
                            self.tripsFeed.append(trip)
                            self.filteredTripsFeed.append(trip)
                        }
                    }
                }
                
                //displays the "No trips" label if there are no trips to display
                if self.filteredTripsFeed.count == 0 {
                    Helper.displayEmptyTableView(withTableView: self.tripsTableView, withText: "No trips to display!")
                    self.emojiView.isHidden = false
                } else {
                    self.emojiView.isHidden = true
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
        getUserRequests()
    }
    
    /*
     * Sets up the cells
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //sets up the headercell
        if indexPath.section == 0 {
            let headerCell = tableView.dequeueReusableCell(withIdentifier: "HomeHeaderCell") as! HomeHeaderCell
            headerCell.selectionStyle = UITableViewCellSelectionStyle.none
            headerCell.delegate = self
            HomeHeaderCell = headerCell
            return headerCell
        }
        //sets up all the other cells (the trip feed)
        else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TripCell", for: indexPath) as! TripCell
            cell.requestButton.isHidden = false //restore default aka request button shows
            cell.requestPendingLabel.isHidden = true
            cell.requestPendingLabel.textColor = Helper.coral()
        
            let trip = filteredTripsFeed[indexPath.row]
            let tripName = trip["Name"] as! String
            
            let departureLocation = trip["DepartureLoc"] as! String
            let arrivalLocation = trip["ArrivalLoc"] as! String
            let earliestDepart = trip["EarliestTime"] as! String
            let latestDepart = trip["LatestTime"] as! String
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
                //cell.tripMembersLabel.text = memberString

                
                if (requestedTrips.contains(trip.objectId!)) {
                    cell.requestButton.isHidden = true
                    cell.requestPendingLabel.isHidden = false
                } else {
                    cell.requestButton.isHidden = false
                    cell.requestPendingLabel.isHidden = true
                }
                
                //hide the "request to join" button if the current user is already in that trip OR if that trip already has 4 ppl in it
                let currentMemberName = PFUser.current()?["firstname"] as! String
                if memberNames.contains(currentMemberName) || memberNames.count == 4 {
                    cell.requestButton.isHidden = true
                }
                
                
                let memberProfPics = Helper.returnMemberProfPics(tripMembers: tripMembers)
                Helper.displayProfilePics(withCell: cell, withMemberPics: memberProfPics)
                
                
                
            }
            //give the request button color
            cell.requestButton.backgroundColor = Helper.peach()
            //Make Button ovular
            cell.requestButton.layer.cornerRadius = cell.requestButton.frame.height / 2
            cell.requestButton.clipsToBounds = true
            
            cell.tripName.text = tripName.capitalized
            cell.departLabel.text = departureLocation
            cell.destinationLabel.text = arrivalLocation
            cell.earlyTimeLabel.text = earliestDepart
            cell.lateDepartLabel.text = latestDepart
            return cell
        }
        
        return UITableViewCell()
    }
    
    
    /*
     * Determines the height of the sections
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 0) {
            return 227
        } else if (indexPath.section == 1) {
            return 170
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
    
    
    func HomeHeaderCell(_ homeHeaderCell: HomeHeaderCell, didTap label: UILabel) {
       
        let config = GMSPlacePickerConfig(viewport: nil)
        let placePicker = GMSPlacePickerViewController(config: config)
        placePicker.delegate = self
        present(placePicker, animated: true, completion: nil)
        
        if(label == HomeHeaderCell.startTextLabel) {
            locationSource = HomeHeaderCell.startTextLabel
        } else if(label == HomeHeaderCell.endTextLabel) {
            locationSource = HomeHeaderCell.endTextLabel
        }
        
    }
    
    
    // To receive the results from the place picker 'self' will need to conform to
    // GMSPlacePickerViewControllerDelegate and implement this code.
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        
        if locationSource == HomeHeaderCell.startTextLabel {
            HomeHeaderCell.startTextLabel.textColor = UIColor.black
            HomeHeaderCell.startTextLabel.text = place.formattedAddress
            print(HomeHeaderCell.startTextLabel.text!)
        } else if locationSource == HomeHeaderCell.endTextLabel {
            HomeHeaderCell.endTextLabel.textColor = UIColor.black
            HomeHeaderCell.endTextLabel.text = place.formattedAddress
        }
        
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        print("Place name \(place.name)")
        print("Place address \(place.formattedAddress)")
        print("Place attributions \(place.attributions)")
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        print("No place selected")
    }
    
    func placePicker(_ viewController: GMSPlacePickerViewController, didFailWithError error: Error) {
        print(error)
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
            performSegue(withIdentifier: "halfModalSegue", sender: nil)
            tripsTableView.reloadData()
        }
    }
    
    
    //====== SEGUE PLACES =======
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "homeToDetail" {
            let cell = sender as! UITableViewCell
            if let indexPath = tripsTableView.indexPath(for: cell) {//get this to find the actual trip
                let trip = filteredTripsFeed[indexPath.row] //get the trip
                let detailViewController = segue.destination as! TripDetailViewController //tell it its destination
                detailViewController.trip = trip
            }
        }
        if segue.identifier == "halfModalSegue" {
            super.prepare(for: segue, sender: sender)
            self.halfModalTransitioningDelegate = HalfModalTransitioningDelegate(viewController: self, presentingViewController: segue.destination)
            segue.destination.modalPresentationStyle = .custom
            segue.destination.transitioningDelegate = self.halfModalTransitioningDelegate
            let navigationController = segue.destination as! HalfModalNavViewController
            let halfModelVC = navigationController.childViewControllers[0] as! HalfModalViewController //tell it its destination
            halfModelVC.currentTrip = currentTrip
        }
    }
    
    @IBAction func didTapGo(_ sender: Any) {
        let departure = HomeHeaderCell.startTextLabel.text!
        let arrival = HomeHeaderCell.endTextLabel.text!
        let earliest = HomeHeaderCell.earliestTextField.text!
        let latest = HomeHeaderCell.latestTextField.text!
        
        //display error message if one of the field is empty
        if departure == " Select Starting Location" || arrival == " Select Ending Location" || earliest == "" || latest == "" {
            present(emptyFieldAlert, animated: true) { }
            return
        }
        //perform the search if all fields are filled
        else {
            let earliestDate = earliest.stringToDate()
            let latestDate = latest.stringToDate()
            filterContent(withDepartureText: departure, withArrivalText: arrival, withEarliestDate: earliestDate, withLatestDate: latestDate)
        }
        //displays the "No trips" label if there are no trips to display
        if self.filteredTripsFeed.count == 0 {
            Helper.displayEmptyTableView(withTableView: self.tripsTableView, withText: "No trips to display!")
            self.emojiView.isHidden = false
        } else {
            emojiView.isHidden = true
        }
    
    }
    
    
    @IBAction func didTapClear(_ sender: Any) {
        HomeHeaderCell.startTextLabel.textColor = UIColor.lightGray
        HomeHeaderCell.endTextLabel.textColor = UIColor.lightGray
        HomeHeaderCell.startTextLabel.text = " Select Starting Location"
        HomeHeaderCell.endTextLabel.text = " Select Ending Location"
    
        HomeHeaderCell.earliestTextField.text = ""
        HomeHeaderCell.earliestTextField.placeholder = "Select Earliest Departure Time"
        HomeHeaderCell.latestTextField.text = ""
        HomeHeaderCell.latestTextField.placeholder = "Select Latest Departure Time"
        
        refresh()
        
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
    
    func getUserRequests() {
        let query = PFQuery(className: "Request")
        query.whereKey("UserID", equalTo: PFUser.current()!.objectId!)
        query.includeKey("Trip")
        query.findObjectsInBackground { (returnedRequests: [PFObject]?, error: Error?) in
            if let returnedRequests = returnedRequests {
                for request in returnedRequests {
                    let requestTrip =  request["Trip"] as! PFObject
                    self.requestedTrips.append(requestTrip.objectId!) 
                }
                self.refresh()
            } else {
                print("Error: \(error?.localizedDescription)")
            }
        }
        

    }
    
    func setProfilePicButton() {
        //set prof pic
        if let profPic = PFUser.current()!["profPic"] as? PFFile {
            profPic.getDataInBackground { (imageData: Data!, error: Error?) in
                let profPic = UIImage(data: imageData)
               self.profileButton.image = profPic
            }
        }
    }
    
    @IBAction func closeKeyboard(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    

}
