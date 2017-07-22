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
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
