//
//  messagesCell.swift
//  CarSharingApp
//
//  Created by Chavane Minto on 7/17/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import UIKit

class messagesCell: UICollectionViewCell {
    
    @IBOutlet weak var messageTitleLabel: UILabel!
    
    @IBOutlet weak var messagePreviewLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
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
    
}
