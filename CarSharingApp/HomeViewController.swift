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

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GMSAutocompleteViewControllerDelegate, HomeHeaderCellDelegate {

    var locationSource: UILabel!
    var autoCompleteViewController: GMSAutocompleteViewController!
    var filter: GMSAutocompleteFilter!
    var HomeHeaderCell: HomeHeaderCell!
    
    var tripsFeed: [PFObject] = []
    //for when the user searches
    var filteredTripsFeed: [PFObject] = []
    
    @IBOutlet weak var earliestTextField: UITextField!
    @IBOutlet weak var latestTextField: UITextField!
    
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
    
    //TODO: Edit so that it changes what appears depending on the search parameters
    func refresh() {
        let query = PFQuery(className: "Trip")
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
    
    //Method for custom header cell in table view
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "HomeHeaderCell") as! HomeHeaderCell
        headerCell.delegate = self
        HomeHeaderCell = headerCell
        return headerCell
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripCell", for: indexPath) as! TripCell
        let trip = tripsFeed[indexPath.row]
        let tripName = trip["Name"] as! String
        let tripPlanner = trip["Planner"] as! PFUser
        let departureLocation = trip["DepartureLoc"] as! String
        let arrivalLocation = trip["ArrivalLoc"] as! String
        let earliestDepart = trip["EarliestTime"] as! NSDate
        let latestDepart = trip["LatestTime"] as! NSDate
        
        cell.tripName.text = tripName
        cell.departLabel.text = departureLocation
        cell.destinationLabel.text = arrivalLocation
        //Might not be possible to do lol
        cell.earlyTimeLabel.text = String(describing: earliestDepart)
        cell.lateDepartLabel.text = String(describing: latestDepart)
        
        return cell
    }
    

    
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //Hardcoded height
        return 170
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //TODO: Set this to be filteredtrips.count
        return tripsFeed.count
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
    
    @IBAction func didTapEarliest(_ sender: Any) {
        print("hi")
        var datePickerView  : UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.dateAndTime
        datePickerView.frame = CGRect(x: 0, y: self.view.frame.height-200, width: self.view.frame.width, height: 200)
        
        // Add an event to call onDidChangeDate function when value is changed.
        datePickerView.addTarget(self, action: #selector(HomeViewController.datePickerValueChanged(_:)), for: .valueChanged)
        
        // Add DataPicker to the view
        self.view.addSubview(datePickerView)
        
    }
    
    func datePickerValueChanged(_ sender: UIDatePicker){
        
        // Create date formatter
        let dateFormatter: DateFormatter = DateFormatter()
        
        // Set date format
        dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a"
        
        // Apply date format
        let selectedDate: String = dateFormatter.string(from: sender.date)
        
        print("Selected value \(selectedDate)")
        HomeHeaderCell.earliestLabel.text = selectedDate //changes the label's text to display date/time
    }
    
    @IBAction func didTapLatest(_ sender: Any) {
        
    }

    
    
    
//    @IBAction func onTapStartLabel(_ sender: Any) {
//        self.present(autoCompleteViewController, animated: true, completion: nil)
//        locationSource = HomeHeaderCell.startTextLabel
//    }
//    
//    cd
//    @IBAction func onTapEndLabel(_ sender: Any) {
//         self.present(autoCompleteViewController, animated: true, completion: nil)
//        locationSource = HomeHeaderCell.endTextLabel
//    }
//    
    

    
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
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
