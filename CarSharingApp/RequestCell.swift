//
//  RequestCell.swift
//  CarSharingApp
//
//  Created by Annabel Strauss on 7/31/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import UIKit

class RequestCell: UITableViewCell {
    
    @IBOutlet weak var tripName: UILabel!
    @IBOutlet weak var newUserName: UILabel!
    @IBOutlet weak var newTime: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var editingLabel: UILabel!
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var denyButton: UIButton!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //give the accept and deny button color
        denyButton.backgroundColor = UIColor.white
        denyButton.layer.borderWidth = 2
        denyButton.layer.borderColor = Helper.teal().cgColor
        acceptButton.backgroundColor = Helper.teal()
        denyButton.setTitleColor(Helper.teal(), for: .normal)
        
        //Make Buttons ovular
        denyButton.layer.cornerRadius = denyButton.frame.height / 2
        acceptButton.layer.cornerRadius = denyButton.frame.height / 2
        denyButton.clipsToBounds = true
        acceptButton.clipsToBounds = true
        
//        newTime.textColor = Helper.coral()
//        tripName.textColor = Helper.coral()
//        newUserName.textColor = Helper.coral()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
