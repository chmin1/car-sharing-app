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
import GooglePlacePicker

//========== THIS IS THE DELEGATE PROTOCOL ==========
protocol CreateViewControllerDelegate: class {
    func didPostTrip(trip: PFObject)
}


class CreateViewController: UIViewController, GMSPlacePickerViewControllerDelegate {
    
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
    var earlyDate: NSDate!
    var lateDate: NSDate!
    var today: NSDate!
    var coordinates = [String: [Double]]()
    
    var invalidLocationsAlert: UIAlertController!
    var invalidTripNameAlert: UIAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = PFUser.current()!

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
        
        //format Create button
        createButton.layer.cornerRadius = createButton.frame.height / 2
        createButton.clipsToBounds = true
        createButton.layer.borderWidth = 2
        createButton.layer.borderColor = UIColor.white.cgColor

    }
    
    override func viewWillAppear(_ animated: Bool) {
        setUpDatePicker()
    }
    
    func setUpTapGesture() {
        let startLabelTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapStartLabel(_sender:))
        )
        let endLabelTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapEndLabel(_sender:))
        )
        startTextLabel.isUserInteractionEnabled = true
        startTextLabel.addGestureRecognizer(startLabelTapGestureRecognizer)
        
        endTextLabel.isUserInteractionEnabled = true
        endTextLabel.addGestureRecognizer(endLabelTapGestureRecognizer)
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
        earlyDate =  today
        
        //create the date picker FOR LATEST and make it appear / be functional
        let LatestDatePickerView  : UIDatePicker = UIDatePicker()
        LatestDatePickerView.minuteInterval = 10
        LatestDatePickerView.datePickerMode = UIDatePickerMode.dateAndTime
        latestTextField.inputView = LatestDatePickerView
        LatestDatePickerView.addTarget(self, action: #selector(self.handleDatePickerForLatest(_:)), for: UIControlEvents.valueChanged)
        lateDate = LatestDatePickerView.date.addingTimeInterval(2000000000000.0*60.0) as NSDate
        
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
        dateFormatter.dateFormat = "MMM d, yyyy h:mm a"
        
        earlyDate = sender.date as NSDate
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
        dateFormatter.dateFormat = "MMM d, yyyy h:mm a"
        
        lateDate = sender.date as NSDate
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
            
            Trip.postTrip(withName: tripName, withDeparture: departureLoc, withArrival: arrivalLoc, withEarliest: earlyDepart, withLatest: lateDepart, withEditID: "", withCoords: coordinates) { (trip: PFObject?, error: Error?) in
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
