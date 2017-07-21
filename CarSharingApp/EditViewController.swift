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
    
    var pendingEditAlert: UIAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up invalid trip alerts
        let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
            // handle cancel response here. Doing nothing will dismiss the view.
        }
        //Invalid Location
        pendingEditAlert = UIAlertController(title: "Pending Edit", message: "There is already an edit in progress for this trip. You must wait until it is approved or denied before making another change.", preferredStyle: .alert)
        pendingEditAlert.addAction(cancelAction)
        
        if let originalTrip = originalTrip {
            if(originalTrip["EditID"] as! String == "") {
                tripNameTextField.text = originalTrip["Name"] as? String
                startTextLabel.text = originalTrip["DepartureLoc"] as? String
                endTextLabel.text = originalTrip["ArrivalLoc"] as? String
                earliestTextField.text = originalTrip["EarliestTime"] as? String
                latestTextField.text = originalTrip["LatestTime"] as? String
            } else {
                present(pendingEditAlert, animated: true) { }
                self.dismiss(animated: true, completion: {})
            }
            
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
