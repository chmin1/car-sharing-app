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

extension UIToolbar {
    
    func ToolbarPiker(mySelect : Selector) -> UIToolbar {
        print("in here")
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: mySelect)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([ spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        return toolBar
    }
    
}

class HomeHeaderCell: UITableViewCell {
    
    @IBOutlet weak var startTextLabel: UILabel!
    @IBOutlet weak var endTextLabel: UILabel!
    @IBOutlet weak var earliestLabel: UILabel!
    @IBOutlet weak var latestTextField: UITextField!
    
    weak var delegate: HomeHeaderCellDelegate?

    
    override func awakeFromNib() {
        super.awakeFromNib()
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
        
        //create the date picker and make it appear / be functional
        var DatePickerView  : UIDatePicker = UIDatePicker()
        DatePickerView.datePickerMode = UIDatePickerMode.dateAndTime
        latestTextField.inputView = DatePickerView
        DatePickerView.addTarget(self, action: #selector(self.handleDatePicker(_:)), for: UIControlEvents.valueChanged)
        
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

    }
    
    func dismissPicker() {
        print("HI")
        latestTextField.resignFirstResponder()
    }


    func handleDatePicker(_ sender: UIDatePicker)
    {
        // Create date formatter
        let dateFormatter: DateFormatter = DateFormatter()
        
        // Set date format
        dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a"
        
        // Apply date format
        let selectedDate: String = dateFormatter.string(from: sender.date)
        latestTextField.text =  selectedDate
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
