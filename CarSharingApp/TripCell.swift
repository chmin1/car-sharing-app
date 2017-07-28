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
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        //make prof pic circular
        onePersonImageView.layer.cornerRadius = onePersonImageView.frame.size.width / 2
        onePersonImageView.clipsToBounds = true
        
        twoPeopleImageView1.layer.cornerRadius = twoPeopleImageView1.frame.size.width / 2
        twoPeopleImageView1.clipsToBounds = true
        
        twoPeopleImageView2.layer.cornerRadius = twoPeopleImageView2.frame.size.width / 2
        twoPeopleImageView2.clipsToBounds = true
        
        threePeopleImageView1.layer.cornerRadius = threePeopleImageView1.frame.size.width / 2
        threePeopleImageView1.clipsToBounds = true
        
        threePeopleImageView2.layer.cornerRadius = threePeopleImageView2.frame.size.width / 2
        threePeopleImageView2.clipsToBounds = true
        
        threePeopleImageView3.layer.cornerRadius = threePeopleImageView3.frame.size.width / 2
        threePeopleImageView3.clipsToBounds = true
        
        fourPeopleImageView1.layer.cornerRadius = fourPeopleImageView1.frame.size.width / 2
        fourPeopleImageView1.clipsToBounds = true
        
        fourPeopleImageView2.layer.cornerRadius = fourPeopleImageView2.frame.size.width / 2
        fourPeopleImageView2.clipsToBounds = true
        
        fourPeopleImageView3.layer.cornerRadius = fourPeopleImageView3.frame.size.width / 2
        fourPeopleImageView3.clipsToBounds = true
        
        fourPeopleImageView4.layer.cornerRadius = fourPeopleImageView4.frame.size.width / 2
        fourPeopleImageView4.clipsToBounds = true
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}
