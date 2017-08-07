//
//  ConvoCell.swift
//  CarSharingApp
//
//  Created by Chavane Minto on 7/19/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import UIKit
import Parse

class ConvoCell: UITableViewCell {
    
    @IBOutlet weak var textImage: UIImageView!
    
    @IBOutlet weak var textMessage: UILabel!
    
    @IBOutlet weak var textBubble: UIView!
    
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var dateSentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        textImage.layer.borderColor = Helper.veryLightGray().cgColor
        textImage.layer.borderWidth = 1
        
//        textBubble.backgroundColor = Helper.peach()
        textBubble.layer.cornerRadius = 7
        textBubble.layer.masksToBounds = true
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
