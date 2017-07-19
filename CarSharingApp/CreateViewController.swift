//
//  CreateViewController.swift
//  CarSharingApp
//
//  Created by Annabel Strauss on 7/13/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import UIKit
import GooglePlaces
import Parse

//========== THIS IS THE DELEGATE PROTOCOL ==========
protocol CreateViewControllerDelegate: class {
    func didPostTrip(trip: PFObject)
}

//========== THIS IS TO GET A DONE BUTTON ON THE DATEPICKER ==========
extension UIToolbar {
    
    func ToolbarPiker(select : Selector) -> UIToolbar {
        print("in here")
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: select)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([ spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        return toolBar
    }
    
}

class CreateViewController: UIViewController, GMSAutocompleteViewControllerDelegate {
    
    @IBOutlet weak var startTextLabel: UILabel!
    @IBOutlet weak var endTextLabel: UILabel!
    @IBOutlet weak var latestTextField: UITextField!
    @IBOutlet weak var earliestTextField: UITextField!
    @IBOutlet weak var tripNameTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    weak var delegate: CreateViewControllerDelegate?
    
    var locationSource: UILabel!
    var autoCompleteViewController: GMSAutocompleteViewController!
    var filter: GMSAutocompleteFilter!
    static let MIN_TIME_WINDOW = 10 //Min time window

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set Up Autocomplete View controller
        filter = GMSAutocompleteFilter()
        filter.type = .address
        autoCompleteViewController = GMSAutocompleteViewController()
        autoCompleteViewController.delegate = self
        autoCompleteViewController.autocompleteFilter = filter
        
        setUpTapGesture()
        setUpDatePicker()

        // Do any additional setup after loading the view.
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
            startTextLabel.text = place.formattedAddress
        } else if locationSource == endTextLabel {
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
        
        latestTextField.text = dateToString(date: LatestDatePickerView.date.addingTimeInterval(120.0*60.0) as NSDate) //two hour window
        
        //create the date picker FOR EARLIEST and make it appear / be functional
        var EarliestDatePickerView  : UIDatePicker = UIDatePicker()
        EarliestDatePickerView.datePickerMode = UIDatePickerMode.dateAndTime
        earliestTextField.inputView = EarliestDatePickerView
        EarliestDatePickerView.addTarget(self, action: #selector(self.handleDatePickerForEarliest(_:)), for: UIControlEvents.valueChanged)
        earliestTextField.text = dateToString(date: EarliestDatePickerView.date as NSDate)
        
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
    
    
    func handleDatePickerForLatest(_ sender: UIDatePicker)
    {
        // Create date formatter
        let dateFormatter: DateFormatter = DateFormatter()
        
        // Set date format
        dateFormatter.dateFormat = "MMM d, h:mm a"
        
        
        // Apply date format
        let selectedDate: String = dateFormatter.string(from: sender.date)
        latestTextField.text =  selectedDate
    }
    
    func handleDatePickerForEarliest(_ sender: UIDatePicker)
    {
        // Create date formatter
        let dateFormatter: DateFormatter = DateFormatter()
        
        // Set date format
        dateFormatter.dateFormat = "MMM d, h:mm a"
        
        // Apply date format
        let selectedDate: String = dateFormatter.string(from: sender.date)
        earliestTextField.text =  selectedDate
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
        
        Trip.postTrip(withName: tripName, withDeparture: departureLoc, withArrival: arrivalLoc, withEarliest: earlyDepart, withLatest: lateDepart) { (trip: PFObject?, error: Error?) in
            if let error = error {
                print("Error creating Trip: \(error.localizedDescription)")
            } else if let trip = trip {
                //add this trip to the user's list of trips
                if var usersTrips = PFUser.current()!["myTrips"] as? [PFObject]{
                    usersTrips.append(trip)
                    PFUser.current()?["myTrips"] = usersTrips
                    PFUser.current()?.saveInBackground()
                }
                //send the trip to the delegate (home vc)
                self.delegate?.didPostTrip(trip: trip)
                print("trip was created! 😃")
                self.activityIndicator.stopAnimating() //stop activity indicator
            }
        }
        
        //TODO: set the text fields and labels back to default state
        
    
    }//close didTapSubmit

    

}
