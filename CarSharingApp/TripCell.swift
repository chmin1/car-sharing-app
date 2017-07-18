//
//  TripCell.swift
//  CarSharingApp
//
//  Created by Elan Halpern on 7/12/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import UIKit

class TripCell: UITableViewCell {

    @IBOutlet weak var tripName: UILabel!
    @IBOutlet weak var departLabel: UILabel!
    @IBOutlet weak var earlyTimeLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var lateDepartLabel: UILabel!
    var requestToJoinAlert: UIAlertController!

    @IBOutlet weak var tripMembersLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Set up the requestToJoinAlert
        requestToJoinAlert = UIAlertController(title: "Requesting To Join Trip", message: "Are you sure you want to join this trip?", preferredStyle: .alert)

        let noAction = UIAlertAction(title: "No", style: .cancel) { (action) in
            // handle cancel response here. Doing nothing will dismiss the view.
        }
        
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            self.addUserToTrip()
        }
        
        requestToJoinAlert.addAction(noAction) // add the no action to the alertController
        requestToJoinAlert.addAction(yesAction) // add the yes action to the alertController
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func didTapRequestToJoin(_ sender: Any) {
        //present(requestToJoinAlert, animated: true) { }
        UIApplication.shared.keyWindow?.rootViewController?.present(requestToJoinAlert, animated: true, completion: nil)
        
    }
    
    func addUserToTrip(){
        print("adding")
    }
    

}
