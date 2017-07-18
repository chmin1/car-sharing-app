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
    
    var tripsFeed: [PFObject] = []
    //for when the user searches
    var filteredTripsFeed: [PFObject] = []
    
    @IBOutlet weak var tripsTableView: UITableView!
    
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set Up Table View
        tripsTableView.delegate = self
        tripsTableView.dataSource = self
        refresh()
        
        //Set Up Autocomplete View controller
        filter = GMSAutocompleteFilter()
        filter.type = .address
        autoCompleteViewController = GMSAutocompleteViewController()
        autoCompleteViewController.delegate = self
        autoCompleteViewController.autocompleteFilter = filter
        
    }
    
    func tabBarController(tabbar: UITabBarController, didSelect: UIViewController) {
        print("HI")
        var secondTab = self.tabBarController?.viewControllers?[1] as? CreateViewController
        secondTab?.delegate = self
        
    }
    
    //TODO: Edit so that it changes what appears depending on the search parameters
    func refresh() {
        let query = PFQuery(className: "Trip")
        query.includeKey("Planner")
        //query.whereKey("Planner", equalTo: PFUser.current())
        //query.order(byDescending: "_created_at")
        query.findObjectsInBackground { (trips: [PFObject]?, error: Error?) in
            if let trips = trips {
                // do something with the array of object returned by the call
                self.tripsFeed.removeAll()
                for trip in trips {
                    self.tripsFeed.append(trip)
                }
                
                self.tripsTableView.reloadData()
                //self.refreshControl.endRefreshing()
            } else {
                print(error?.localizedDescription)
            }
            
        }
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
            let trip = tripsFeed[indexPath.row]
            let tripName = trip["Name"] as! String
            let organizer = trip["Planner"] as! PFUser
            let firstname = organizer["firstname"] as! String
            let lastname = organizer["lastname"] as! String
            let departureLocation = trip["DepartureLoc"] as! String
            let arrivalLocation = trip["ArrivalLoc"] as! String
            let earliestDepart = trip["EarliestTime"] as! String
            let latestDepart = trip["LatestTime"] as! String
            
            
            cell.tripName.text = tripName
            cell.departLabel.text = departureLocation
            cell.destinationLabel.text = arrivalLocation
            cell.earlyTimeLabel.text = earliestDepart
            cell.lateDepartLabel.text = latestDepart
            cell.organizerLabel.text = firstname + " " + lastname
            return cell
        }
        
        return UITableViewCell()
    }
    

    /*
     * Determines the height of the sections
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 0) {
            return 170
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
        //section 1 has tripsFeed.count rows
        else if (section == 1) {
            //TODO: Set this to be filteredtrips.count
            return tripsFeed.count
        }
        return 0
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func HomeHeaderCell(_ homeHeaderCell: HomeHeaderCell, didTap label: UILabel) {
        self.present(autoCompleteViewController, animated: true, completion: nil)
        if(label == HomeHeaderCell.startTextLabel) {
            locationSource = HomeHeaderCell.startTextLabel
            print("Location source is start")
        } else if(label == HomeHeaderCell.endTextLabel) {
            locationSource = HomeHeaderCell.endTextLabel
            print("location source is end")
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
            print(place.name)
            //HomeHeaderCell.startTextLabel.text = place.name
            HomeHeaderCell.startTextLabel.text = place.name
            print(HomeHeaderCell.startTextLabel.text!)
        } else if locationSource == HomeHeaderCell.endTextLabel {
            print(place.name)
            HomeHeaderCell.endTextLabel.text = place.name
        }
//        self.tripsTableView.reloadData()
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

    
    @IBAction func didTapLogout(_ sender: Any) {
        //logs user out
        NotificationCenter.default.post(name: NSNotification.Name("logoutNotification"), object: nil)
        PFUser.logOutInBackground(block: { (error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Successful loggout")
            }
        })
    }
    
    func didPostTrip(trip: PFObject) {
        print("did post trip")
        tripsFeed.insert(trip, at: 0)
        tripsTableView.reloadData()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createSegue" {
            let createViewController = segue.destination as! CreateViewController
            createViewController.delegate = self
        }
    }

}
