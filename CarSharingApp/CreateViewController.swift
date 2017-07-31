//
//  CreateViewController.swift
//  CarSharingApp
//
//  Created by Annabel Strauss on 7/13/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import Parse

//========== THIS IS THE DELEGATE PROTOCOL ==========
protocol CreateViewControllerDelegate: class {
    func didPostTrip(trip: PFObject)
}


class CreateViewController: UIViewController, GMSAutocompleteViewControllerDelegate {
    
    @IBOutlet weak var startTextLabel: UILabel!
    @IBOutlet weak var endTextLabel: UILabel!
    @IBOutlet weak var latestTextField: UITextField!
    @IBOutlet weak var earliestTextField: UITextField!
    @IBOutlet weak var tripNameTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var createButton: UIButton!
    
    @IBOutlet weak var minTimeLabel: UILabel!
    
    weak var delegate: CreateViewControllerDelegate?
    
    var locationSource: UILabel!
    var autoCompleteViewController: GMSAutocompleteViewController!
    var filter: GMSAutocompleteFilter!
    
    var earlyDate: NSDate!
    var lateDate: NSDate!
    var today: NSDate!
    
    var invalidLocationsAlert: UIAlertController!
    var invalidTripNameAlert: UIAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = PFUser.current()!
        
        //Set Up Autocomplete View controller
        filter = GMSAutocompleteFilter()
        filter.type = .address
        filter.type = .establishment
        filter.type = .geocode
        filter.country = "US"
        autoCompleteViewController = GMSAutocompleteViewController()
        autoCompleteViewController.delegate = self
        autoCompleteViewController.autocompleteFilter = filter
        
        setUpTapGesture()
        setUpDatePicker()
        
        //Set up invalid trip alerts
        let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
            // handle cancel response here. Doing nothing will dismiss the view.
        }
        //Invalid Location
        invalidLocationsAlert = UIAlertController(title: "Invalid Trip", message: "The start and end locations cannot be the same", preferredStyle: .alert)
        invalidLocationsAlert.addAction(cancelAction)

        //Invalid Trip Name
        invalidTripNameAlert = UIAlertController(title: "Invalid Trip", message: "You must create a trip name", preferredStyle: .alert)
        invalidTripNameAlert.addAction(cancelAction)
        
        //set background and text color of Nav bar
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = Helper.coral()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        minTimeLabel.textColor = Helper.coral()
        //Make Create Button circular
        createButton.layer.cornerRadius = 0.15 * createButton.bounds.size.width
        createButton.clipsToBounds = true
        createButton.backgroundColor = Helper.coral()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        setUpDatePicker()
    }
    
    func setUpTapGesture() {
        let startLabelTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapStartLabel(_sender:))
        )
        let endLabelTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapEndLabel(_sender:))
        )
        startTextLabel.layer.borderColor = Helper.veryLightGray().cgColor
        startTextLabel.layer.borderWidth = 0.5
        startTextLabel.addGestureRecognizer(startLabelTapGestureRecognizer)
        startTextLabel.isUserInteractionEnabled = true
        startTextLabel.layer.cornerRadius = startTextLabel.frame.height / 5
        startTextLabel.clipsToBounds = true
        
        endTextLabel.layer.borderColor = Helper.veryLightGray().cgColor
        endTextLabel.layer.borderWidth = 0.5
        endTextLabel.addGestureRecognizer(endLabelTapGestureRecognizer)
        endTextLabel.isUserInteractionEnabled = true
        endTextLabel.layer.cornerRadius = endTextLabel.frame.height / 5
        endTextLabel.clipsToBounds = true
    }
    
    func didTapStartLabel(_sender: UITapGestureRecognizer) {
        locationSource = startTextLabel
        self.present(autoCompleteViewController, animated: true, completion: nil)
        print("Tapped start label")
    }
    
    func didTapEndLabel(_sender: UITapGestureRecognizer) {
        locationSource = endTextLabel
        self.present(autoCompleteViewController, animated: true, completion: nil)
        print("Tapped End label")
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
        if locationSource == startTextLabel {
            startTextLabel.textColor = UIColor.black
            startTextLabel.text = place.name
        } else if locationSource == endTextLabel {
            endTextLabel.textColor = UIColor.black
            endTextLabel.text = place.name
        }
        self.dismiss(animated: true)
    }
    
    func setUpDatePicker() {
        //create the date picker FOR LATEST and make it appear / be functional
        var LatestDatePickerView  : UIDatePicker = UIDatePicker()
        LatestDatePickerView.datePickerMode = UIDatePickerMode.dateAndTime
        latestTextField.inputView = LatestDatePickerView
        LatestDatePickerView.addTarget(self, action: #selector(self.handleDatePickerForLatest(_:)), for: UIControlEvents.valueChanged)
        lateDate = LatestDatePickerView.date.addingTimeInterval(120.0*60.0) as NSDate
        latestTextField.text = Helper.dateToString(date: lateDate) //two hour window
        
        //create the date picker FOR EARLIEST and make it appear / be functional
        var EarliestDatePickerView  : UIDatePicker = UIDatePicker()
        EarliestDatePickerView.datePickerMode = UIDatePickerMode.dateAndTime
        earliestTextField.inputView = EarliestDatePickerView
        EarliestDatePickerView.addTarget(self, action: #selector(self.handleDatePickerForEarliest(_:)), for: UIControlEvents.valueChanged)
        
        today = EarliestDatePickerView.date as NSDate
        earlyDate =  today
        earliestTextField.text = Helper.dateToString(date: earlyDate)
        
        //create the toolbar so there's a Done button in the datepicker
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.dismissPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([ spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        latestTextField.inputAccessoryView = toolBar
        earliestTextField.inputAccessoryView = toolBar
    }
    
    /*
     * Dismiss datepicker when Done button pressed
     */
    func dismissPicker() {
        latestTextField.resignFirstResponder()
        earliestTextField.resignFirstResponder()
    }
    
    
    func handleDatePickerForEarliest(_ sender: UIDatePicker)
    {
        // Create date formatter
        let dateFormatter: DateFormatter = DateFormatter()
        
        // Set date format
        dateFormatter.dateFormat = "MMM d, YYYY h:mm a"
        
        let maximumDate = lateDate.addMinutes(minutesToAdd: -20)
        sender.maximumDate = maximumDate as Date
        sender.minimumDate = today as NSDate as Date

        earlyDate = sender.date as NSDate
        let selectedDate: String = dateFormatter.string(from: sender.date)
        earliestTextField.text =  selectedDate
        
    }
    
    
    func handleDatePickerForLatest(_ sender: UIDatePicker)
    {
        // Create date formatter
        let dateFormatter: DateFormatter = DateFormatter()
        
        // Set date format
        dateFormatter.dateFormat = "MMM d, YYYY h:mm a"
        
        let minimumDate = earlyDate.addMinutes(minutesToAdd: 20)
        sender.minimumDate = minimumDate as Date
        
        lateDate = sender.date as NSDate
        
        let selectedDate: String = dateFormatter.string(from: sender.date)
        latestTextField.text =  selectedDate
        
    }
    

    func areValidLocations(depart: String, destination: String) -> Bool {
        if(depart == destination) {
            present(invalidLocationsAlert, animated: true) { }
            return false
        } else if (depart == "Add Start Location" || destination == "Add End Location") {
            return false
        }
        return true
    }
    
    func isValidTripName(tripName: String) -> Bool {
        if tripName == "" {
            present(invalidTripNameAlert, animated:  true) { }
            return false
        }
        return true
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
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    //Get Place Predictions Programmatically
    //Call GMSPlacesClient
    func placeAutocomplete() {
        let filter = GMSAutocompleteFilter()
        filter.type = .address //was .establishment
        let placesClient = GMSPlacesClient()
        placesClient.autocompleteQuery("", bounds: nil, filter: filter, callback: {(results, error) -> Void in
            if let error = error {
                print("Autocomplete error \(error)")
                return
            }
            if let results = results {
                for result in results {
                    print("Result \(result.attributedFullText) with placeID \(result.placeID)")
                }
            }
        })
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
        dismiss(animated: true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     * Create a new Trip object and send it to parse when user taps the submit button
     */
    @IBAction func didTapSubmit(_ sender: Any) {
        
        // Start the activity indicator
        activityIndicator.startAnimating()
        
        let tripName = tripNameTextField.text
        let departureLoc = startTextLabel.text
        let arrivalLoc = endTextLabel.text
        let earlyDepart = earliestTextField.text
        let lateDepart = latestTextField.text
        
        if areValidLocations(depart: departureLoc!, destination: arrivalLoc!) && isValidTripName(tripName: tripName!) {
            
            Trip.postTrip(withName: tripName, withDeparture: departureLoc, withArrival: arrivalLoc, withEarliest: earlyDepart, withLatest: lateDepart, withEditID: "") { (trip: PFObject?, error: Error?) in
                if let error = error {
                    print("Error creating Trip: \(error.localizedDescription)")
                } else if let trip = trip {
                    //send the trip to the delegate (home vc)
                    self.delegate?.didPostTrip(trip: trip)
                    print("trip was created! 😃")
                    self.activityIndicator.stopAnimating() //stop activity indicator
                }
            }
        } else {
            self.activityIndicator.stopAnimating()
            print("Invalid trip")
        }
        
        //Set the text fields and labels back to default state
        tripNameTextField.text = ""
        tripNameTextField.placeholder = "Trip Name"
        startTextLabel.textColor = UIColor.lightGray
        endTextLabel.textColor = UIColor.lightGray
        startTextLabel.text = " Add Start Location"
        endTextLabel.text = " Add End Location"
        
    }//close didTapSubmit
    
    
    
}
