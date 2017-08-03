//
//  EditedTripCell.swift
//  CarSharingApp
//
//  Created by Annabel Strauss on 7/21/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import UIKit

class EditedTripCell: UITableViewCell {

    
    @IBOutlet weak var originalTripNameLabel: UILabel!
    @IBOutlet weak var newTripNameLabel: UILabel!
    @IBOutlet weak var tripMembersLabel: UILabel!
    @IBOutlet weak var departLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var earlyTimeLabel: UILabel!
    @IBOutlet weak var lateDepartLabel: UILabel!
    @IBOutlet weak var denyButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var editingLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //give the accept and deny button color
        denyButton.backgroundColor = UIColor.white
        denyButton.layer.borderWidth = 2
        denyButton.layer.borderColor = Helper.peach().cgColor
        acceptButton.backgroundColor = Helper.peach()
        denyButton.setTitleColor(Helper.peach(), for: .normal)
        
        editingLabel.textColor = Helper.coral()
        originalTripNameLabel.textColor = Helper.coral()
        
        //Make Buttons ovular
        denyButton.layer.cornerRadius = denyButton.frame.height / 2
        acceptButton.layer.cornerRadius = denyButton.frame.height / 2
        denyButton.clipsToBounds = true
        acceptButton.clipsToBounds = true

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
