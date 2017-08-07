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
    @IBOutlet weak var requestButton: UIButton!
    @IBOutlet weak var tripMembersLabel: UILabel!
    @IBOutlet weak var requestPendingLabel: UILabel!
    
    @IBOutlet weak var onePersonImageView: UIImageView!
    @IBOutlet weak var twoPeopleImageView1: UIImageView!
    @IBOutlet weak var twoPeopleImageView2: UIImageView!
    @IBOutlet weak var threePeopleImageView1: UIImageView!
    @IBOutlet weak var threePeopleImageView2: UIImageView!
    @IBOutlet weak var threePeopleImageView3: UIImageView!
    @IBOutlet weak var fourPeopleImageView1: UIImageView!
    @IBOutlet weak var fourPeopleImageView2: UIImageView!
    @IBOutlet weak var fourPeopleImageView3: UIImageView!
    @IBOutlet weak var fourPeopleImageView4: UIImageView!
    
    @IBOutlet weak var onePersonOverlay: UIImageView!
    @IBOutlet weak var twoPeopleOverlay: UIImageView!
    @IBOutlet weak var threePeopleOverlay: UIImageView!
    @IBOutlet weak var fourPeopleOverlay: UIImageView!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()

        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}
