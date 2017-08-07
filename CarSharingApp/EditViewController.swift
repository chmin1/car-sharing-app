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
import GooglePlacePicker

class EditViewController: UIViewController, GMSPlacePickerViewControllerDelegate {
    
    var originalTrip: PFObject?
    
    @IBOutlet weak var tripNameTextField: UITextField!
    @IBOutlet weak var startTextLabel: UILabel!
    @IBOutlet weak var endTextLabel: UILabel!
    @IBOutlet weak var earliestTextField: UITextField!
    @IBOutlet weak var latestTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var submitButton: UIButton!
    
    
    @IBOutlet weak var minTimeLabel: UILabel!
    var locationSource: UILabel!
    
    static let MIN_TIME_WINDOW = 10 //Min time window
    var earlyDate: NSDate!
    var lateDate: NSDate!
    var today: NSDate!
    var coordinates = [String: [Double]]()

    var invalidLocationsAlert: UIAlertController!
    var invalidTimeWindowAlert: UIAlertController!
    var invalidTripNameAlert: UIAlertController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpInvalidTripAlerts()
        setUpTapGesture()
        setUpDatePicker()
        
        //Make Buttons ovular and color their background/text
        submitButton.layer.cornerRadius = submitButton.frame.height / 2
        submitButton.clipsToBounds = true
        submitButton.backgroundColor = Helper.peach()
        submitButton.setTitleColor(UIColor.white, for: .normal)
        
        //Fill in the trip info
        if let originalTrip = originalTrip {
            let name = originalTrip["Name"] as? String
            tripNameTextField.text = name?.capitalized
            startTextLabel.text = originalTrip["DepartureLoc"] as? String
            endTextLabel.text = originalTrip["ArrivalLoc"] as? String
            
            earlyDate = originalTrip["EarliestDate"] as! NSDate
            lateDate = originalTrip["LatestDate"] as! NSDate
            
            earliestTextField.text = Helper.dateToString(date: earlyDate)
            latestTextField.text = Helper.dateToString(date: lateDate)
        }
        
        minTimeLabel.textColor = Helper.coral()
        
        
        
    }
    
    
    func setUpInvalidTripAlerts() {
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
        startTextLabel.textColor = UIColor.black
        
        endTextLabel.layer.borderColor = Helper.veryLightGray().cgColor
        endTextLabel.layer.borderWidth = 0.5
        endTextLabel.addGestureRecognizer(endLabelTapGestureRecognizer)
        endTextLabel.isUserInteractionEnabled = true
        endTextLabel.layer.cornerRadius = endTextLabel.frame.height / 5
        endTextLabel.clipsToBounds = true
        endTextLabel.textColor = UIColor.black
    }
    
    func didTapStartLabel(_sender: UITapGestureRecognizer) {
        locationSource = startTextLabel
        let config = GMSPlacePickerConfig(viewport: nil)
        let placePicker = GMSPlacePickerViewController(config: config)
        placePicker.delegate = self
        present(placePicker, animated: true, completion: nil)
    }
    
    func didTapEndLabel(_sender: UITapGestureRecognizer) {
        locationSource = endTextLabel
        let config = GMSPlacePickerConfig(viewport: nil)
        let placePicker = GMSPlacePickerViewController(config: config)
        placePicker.delegate = self
        present(placePicker, animated: true, completion: nil)
    }
    
    // To receive the results from the place picker 'self' will need to conform to
    // GMSPlacePickerViewControllerDelegate and implement this code.
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        
        if locationSource == startTextLabel {
            startTextLabel.textColor = UIColor.white
            startTextLabel.text = place.formattedAddress
            coordinates["from"] = [place.coordinate.latitude, place.coordinate.longitude]
        } else if locationSource == endTextLabel {
            endTextLabel.textColor = UIColor.white
            endTextLabel.text = place.formattedAddress
            coordinates["to"] = [place.coordinate.latitude, place.coordinate.longitude]
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
    
    func setUpDatePicker() {
        //create the date picker FOR EARLIEST and make it appear / be functional
        let EarliestDatePickerView  : UIDatePicker = UIDatePicker()
        EarliestDatePickerView.minuteInterval = 10
        EarliestDatePickerView.datePickerMode = UIDatePickerMode.dateAndTime
        earliestTextField.inputView = EarliestDatePickerView
        EarliestDatePickerView.addTarget(self, action: #selector(self.handleDatePickerForEarliest(_:)), for: UIControlEvents.valueChanged)
        
        today = Helper.currentTimeToNearest10()
        //earlyDate =  today
        
        //create the date picker FOR LATEST and make it appear / be functional
        let LatestDatePickerView  : UIDatePicker = UIDatePicker()
        LatestDatePickerView.minuteInterval = 10
        LatestDatePickerView.datePickerMode = UIDatePickerMode.dateAndTime
        latestTextField.inputView = LatestDatePickerView
        LatestDatePickerView.addTarget(self, action: #selector(self.handleDatePickerForLatest(_:)), for: UIControlEvents.valueChanged)
        
        //lateDate = LatestDatePickerView.date.addingTimeInterval(2000000000000.0*60.0) as NSDate

        
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
        dateFormatter.dateFormat = "MMM d h:mm a"
        
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
        dateFormatter.dateFormat = "MMM d h:mm a"
        
        let minimumDate = earlyDate.addMinutes(minutesToAdd: 20)
        sender.minimumDate = minimumDate as Date
        
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
    
    
    /*
     * Create a new Trip object and send it to parse when user taps the submit button
     */
    @IBAction func didTapSubmit(_ sender: Any) {
        
        // Start the activity indicator
        activityIndicator.startAnimating()
        
        let tripName = tripNameTextField.text
        let departureLoc = startTextLabel.text
        let arrivalLoc = endTextLabel.text
        
        if isValidDateWindow(earlyDate: earlyDate, lateDate: lateDate) && areValidLocations(depart: departureLoc!, destination: arrivalLoc!) && isValidTripName(tripName: tripName!) {
            
            Trip.postTrip(withName: tripName, withDeparture: departureLoc, withArrival: arrivalLoc, withEarliest: earlyDate, withLatest: lateDate, withEditID: "-1", withCoords: coordinates) { (trip: PFObject?, error: Error?) in
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
        
    }
    
    @IBAction func closeKeyboard(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapCancel(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
}
