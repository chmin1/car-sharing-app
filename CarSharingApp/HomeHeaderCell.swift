//
//  HomeHeaderCell.swift
//  CarSharingApp
//
//  Created by Elan Halpern on 7/12/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import UIKit

protocol HomeHeaderCellDelegate: class {
    func HomeHeaderCell(_ homeHeaderCell: HomeHeaderCell, didTap label: UILabel)
}

class HomeHeaderCell: UITableViewCell {
    
    @IBOutlet weak var startTextLabel: UILabel!
    @IBOutlet weak var endTextLabel: UILabel!
    @IBOutlet weak var earliestTextField: UITextField!
    @IBOutlet weak var latestTextField: UITextField!
    
    @IBOutlet weak var minTimeLabel: UILabel!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    
    
    weak var delegate: HomeHeaderCellDelegate?
    
    var earlyDate: NSDate!
    var lateDate: NSDate!
    var today: NSDate!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //Set up tap gesture recognizer for start and end labels
        let startLabelTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapStartLabel(_sender:))
        )
        let endLabelTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapEndLabel(_sender:))
        )
        
        //Add boarder to start and end labels
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
        
        //Make Go Button circular
        goButton.layer.cornerRadius = 0.15 * goButton.bounds.size.width
        goButton.clipsToBounds = true
        goButton.backgroundColor = Helper.coral()
        
        //Make Clear Button Circular
        clearButton.layer.cornerRadius = 0.15 * goButton.bounds.size.width
        clearButton.clipsToBounds = true
        clearButton.backgroundColor = Helper.teal()
        
        //create the date picker FOR EARLIEST and make it appear / be functional
        var EarliestDatePickerView  : UIDatePicker = UIDatePicker()
        EarliestDatePickerView.datePickerMode = UIDatePickerMode.dateAndTime
        earliestTextField.inputView = EarliestDatePickerView
        EarliestDatePickerView.addTarget(self, action: #selector(self.handleDatePickerForEarliest(_:)), for: UIControlEvents.valueChanged)
        today = EarliestDatePickerView.date as NSDate
        earlyDate =  today
        //earliestTextField.text = dateToString(date: EarliestDatePickerView.date as NSDate)
        
        //create the date picker FOR LATEST and make it appear / be functional
        var LatestDatePickerView  : UIDatePicker = UIDatePicker()
        LatestDatePickerView.datePickerMode = UIDatePickerMode.dateAndTime
        latestTextField.inputView = LatestDatePickerView
        LatestDatePickerView.addTarget(self, action: #selector(self.handleDatePickerForLatest(_:)), for: UIControlEvents.valueChanged)
        lateDate = LatestDatePickerView.date.addingTimeInterval(120.0*60.0) as NSDate
        //latestTextField.text = Helper.dateToString(date: lateDate) //two hour window
        
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

        minTimeLabel.textColor = Helper.coral()
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
        dateFormatter.dateFormat = "MMM d, YYYY h:mm a"
        // Apply date format
        let selectedDate: String = dateFormatter.string(from: date as Date)
        return selectedDate
    }

    func handleDatePickerForLatest(_ sender: UIDatePicker)
    {
        // Create date formatter
        let dateFormatter: DateFormatter = DateFormatter()
        
        // Set date format
        dateFormatter.dateFormat = "MMM d, YYYY h:mm a"
        
        let minimumDate = earlyDate.addMinutes(minutesToAdd: 20)
        sender.minimumDate = minimumDate as Date
        
        // Apply date format
        let selectedDate: String = dateFormatter.string(from: sender.date)
        latestTextField.text =  selectedDate
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
        
        // Apply date format
        let selectedDate: String = dateFormatter.string(from: sender.date)
        earliestTextField.text =  selectedDate
    }
    
    func didTapStartLabel(_sender: UITapGestureRecognizer) {
        delegate?.HomeHeaderCell(self, didTap: startTextLabel)
        print("Tapped start label")
    }
    
    func didTapEndLabel(_sender: UITapGestureRecognizer) {
        delegate?.HomeHeaderCell(self, didTap: endTextLabel)
        print("Tapped End label")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}
