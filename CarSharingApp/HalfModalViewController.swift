//
//  HalfModalViewController.swift
//  CarSharingApp
//
//  Created by Annabel Strauss on 7/28/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import UIKit

class HalfModalViewController: UIViewController, HalfModalPresentable {

    @IBOutlet weak var myDatePicker: UIDatePicker!
    var newTime: String = ""
    
    override func viewWillAppear(_ animated: Bool) {
        newTime = setUpDatePicker(date: myDatePicker.date)
        print("original new time = \(newTime)")
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        if let delegate = navigationController?.transitioningDelegate as? HalfModalTransitioningDelegate {
            delegate.interactiveDismiss = false
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func setUpDatePicker(date: Date) -> String {
        // Create date formatter
        let dateFormatter: DateFormatter = DateFormatter()
        
        // Set date format
        dateFormatter.dateFormat = "MMM d, h:mm a"
        
        // Apply date format
        let selectedDate: String = dateFormatter.string(from: date as Date)
        
        return selectedDate
    }
    
    @IBAction func changeTimeDatePickerAction(_ sender: Any) {
        newTime = setUpDatePicker(date: myDatePicker.date)
        print("new time = \(newTime)")
    }
    
    @IBAction func didTapChangeTime(_ sender: Any) {
        //HomeViewController.addUserToTrip()
    }

    @IBAction func didTapLeaveTime(_ sender: Any) {
        //HomeViewController.addUserToTrip()
    }
    

}
