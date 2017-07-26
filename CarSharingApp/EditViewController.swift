//
//  EditViewController.swift
//  CarSharingApp
//
//  Created by Elan Halpern on 7/20/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import UIKit
import GooglePlaces
import Parse


class EditViewController: UIViewController, GMSAutocompleteViewControllerDelegate {
    
    var originalTrip: PFObject?
    
    @IBOutlet weak var tripNameTextField: UITextField!
    @IBOutlet weak var startTextLabel: UILabel!
    @IBOutlet weak var endTextLabel: UILabel!
    @IBOutlet weak var earliestTextField: UITextField!
    @IBOutlet weak var latestTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var locationSource: UILabel!
    var autoCompleteViewController: GMSAutocompleteViewController!
    var filter: GMSAutocompleteFilter!
    
    static let MIN_TIME_WINDOW = 10 //Min time window
    var earlyDate: NSDate!
    var lateDate: NSDate!
    
    var invalidLocationsAlert: UIAlertController!
    var invalidTimeWindowAlert: UIAlertController!
    var invalidTripNameAlert: UIAlertController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up invalid trip alerts
        let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
            // handle cancel response here. Doing nothing will dismiss the view.
        }
        
        //Invalid Location
        invalidLocationsAlert = UIAlertController(title: "Invalid Trip", message: "The start and end locations cannot be the same", preferredStyle: .alert)
        invalidLocationsAlert.addAction(cancelAction)
        
        //Invalid Time Window
        invalidTimeWindowAlert = UIAlertController(title: "Invalid Trip", message: "There must be at least a 20 minute time window", preferredStyle: .alert)
        invalidTimeWindowAlert.addAction(cancelAction)
        
        //Invalid Trip Name
        invalidTripNameAlert = UIAlertController(title: "Invalid Trip", message: "You must create a trip name", preferredStyle: .alert)
        invalidTripNameAlert.addAction(cancelAction)
        
        //Fill in the trip info
        if let originalTrip = originalTrip {
            tripNameTextField.text = originalTrip["Name"] as? String
            startTextLabel.text = originalTrip["DepartureLoc"] as? String
            endTextLabel.text = originalTrip["ArrivalLoc"] as? String
            earliestTextField.text = originalTrip["EarliestTime"] as? String
            latestTextField.text = originalTrip["LatestTime"] as? String
        }
        
        //Set Up Autocomplete View controller
        filter = GMSAutocompleteFilter()
        filter.type = .address
        autoCompleteViewController = GMSAutocompleteViewController()
        autoCompleteViewController.delegate = self
        autoCompleteViewController.autocompleteFilter = filter
        
        setUpTapGesture()
        setUpDatePicker()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapCancel(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    func setUpTapGesture() {
        let startLabelTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapStartLabel(_sender:))
        )
        let endLabelTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapEndLabel(_sender:))
        )
        startTextLabel.layer.borderColor = UIColor.gray.cgColor
        startTextLabel.layer.borderWidth = 0.5
        startTextLabel.addGestureRecognizer(startLabelTapGestureRecognizer)
        startTextLabel.isUserInteractionEnabled = true
        
        endTextLabel.layer.borderColor = UIColor.gray.cgColor
        endTextLabel.layer.borderWidth = 0.5
        endTextLabel.addGestureRecognizer(endLabelTapGestureRecognizer)
        endTextLabel.isUserInteractionEnabled = true
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
            startTextLabel.text = place.formattedAddress
        } else if locationSource == endTextLabel {
            endTextLabel.textColor = UIColor.black
            endTextLabel.text = place.formattedAddress
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
        latestTextField.text = dateToString(date: lateDate) //two hour window
        
        //create the date picker FOR EARLIEST and make it appear / be functional
        var EarliestDatePickerView  : UIDatePicker = UIDatePicker()
        EarliestDatePickerView.datePickerMode = UIDatePickerMode.dateAndTime
        earliestTextField.inputView = EarliestDatePickerView
        EarliestDatePickerView.addTarget(self, action: #selector(self.handleDatePickerForEarliest(_:)), for: UIControlEvents.valueChanged)
        earlyDate =  EarliestDatePickerView.date as NSDate
        earliestTextField.text = dateToString(date: earlyDate)
        
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
    
    func dateToString(date: NSDate) -> String {
        // Create date formatter
        let dateFormatter: DateFormatter = DateFormatter()
        
        // Set date format
        dateFormatter.dateFormat = "MMM d, h:mm a"
        
        // Apply date format
        let selectedDate: String = dateFormatter.string(from: date as Date)
        return selectedDate
    }
    
    
    func handleDatePickerForEarliest(_ sender: UIDatePicker)
    {
        // Create date formatter
        let dateFormatter: DateFormatter = DateFormatter()
        
        // Set date format
        dateFormatter.dateFormat = "MMM d, h:mm a"
        
        earlyDate = sender.date as NSDate
        let selectedDate: String = dateFormatter.string(from: sender.date)
        earliestTextField.text =  selectedDate
        
    }
    
    
    func handleDatePickerForLatest(_ sender: UIDatePicker)
    {
        // Create date formatter
        let dateFormatter: DateFormatter = DateFormatter()
        
        // Set date format
        dateFormatter.dateFormat = "MMM d, h:mm a"
        
        lateDate = sender.date as NSDate
        
        let selectedDate: String = dateFormatter.string(from: sender.date)
        latestTextField.text =  selectedDate
        
    }
    
    func isValidDateWindow(earlyDate: NSDate, lateDate: NSDate) -> Bool {
        
        if(earlyDate.addMinutes(minutesToAdd: 20).isGreaterThanDate(dateToCompare: lateDate)) {
            present(invalidTimeWindowAlert, animated: true) { }
            return false
        }
        //TODO: Do other checks so you can have other print statements
        return true
    }
    
    func areValidLocations(depart: String, destination: String) -> Bool {
        if(depart == destination) {
            present(invalidLocationsAlert, animated: true) { }
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
        
        if isValidDateWindow(earlyDate: earlyDate, lateDate: lateDate) && areValidLocations(depart: departureLoc!, destination: arrivalLoc!) && isValidTripName(tripName: tripName!) {
            
            Trip.postTrip(withName: tripName, withDeparture: departureLoc, withArrival: arrivalLoc, withEarliest: earlyDepart, withLatest: lateDepart, withEditID: "-1") { (trip: PFObject?, error: Error?) in
                if let error = error {
                    print("Error creating Trip: \(error.localizedDescription)")
                }
                else if let trip = trip {
                    
                    //store a reference to this edit in the original trip
                    self.originalTrip?["EditID"] = trip.objectId!
                    self.originalTrip?.saveInBackground(block: { (success: Bool, error:Error?) in
                        if let error = error {
                            print("Error creating Trip: \(error.localizedDescription)")
                        } else {
                            print("trip saved properly🐠🐠🐠🐠🐠")
                        }
                    })
                    self.activityIndicator.stopAnimating() //stop activity indicator
                    //TODO: send notification
                    self.dismiss(animated: true)
                }
            }//close postTrip
        } else {
            self.activityIndicator.stopAnimating()
            print("Invalid edit (aka invalid trip)")
        }
        
    }//close didTapSubmit()
    
    
    
    @IBAction func didTapDeleteTrip(_ sender: Any) {
        //NotificationsViewController.deleteTrip(trip: originalTrip!)

        
    }
    
    
}//close class
