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
    
    
    var locationSource: UILabel!
    var autoCompleteViewController: GMSAutocompleteViewController!
    var filter: GMSAutocompleteFilter!

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
            startTextLabel.text = place.name
        } else if locationSource == endTextLabel {
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
        
        //create the date picker FOR EARLIEST and make it appear / be functional
        var EarliestDatePickerView  : UIDatePicker = UIDatePicker()
        EarliestDatePickerView.datePickerMode = UIDatePickerMode.dateAndTime
        earliestTextField.inputView = EarliestDatePickerView
        EarliestDatePickerView.addTarget(self, action: #selector(self.handleDatePickerForEarliest(_:)), for: UIControlEvents.valueChanged)
        
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
        print("HI")
        latestTextField.resignFirstResponder()
        earliestTextField.resignFirstResponder()
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
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
