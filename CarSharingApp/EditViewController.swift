//
//  EditViewController.swift
//  CarSharingApp
//
//  Created by Elan Halpern on 7/20/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import UIKit
import Parse

class EditViewController: UIViewController {

    var originalTrip: PFObject?
    
    @IBOutlet weak var tripNameTextField: UITextField!
    @IBOutlet weak var startTextLabel: UILabel!
    @IBOutlet weak var endTextLabel: UILabel!
    @IBOutlet weak var earliestTextField: UITextField!
    @IBOutlet weak var latestTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let originalTrip = originalTrip {
            tripNameTextField.text = originalTrip["Name"] as? String
            startTextLabel.text = originalTrip["DepartureLoc"] as? String
            endTextLabel.text = originalTrip["ArrivalLoc"] as? String
            earliestTextField.text = originalTrip["EarliestTime"] as? String
            latestTextField.text = originalTrip["LatestTime"] as? String
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapCancel(_ sender: Any) {
        self.dismiss(animated: true)
    }

    

}
