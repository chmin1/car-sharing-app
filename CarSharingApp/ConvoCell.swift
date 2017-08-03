//
//  ConvoCell.swift
//  CarSharingApp
//
//  Created by Chavane Minto on 7/19/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import UIKit

class ConvoCell: UITableViewCell {
    
    @IBOutlet weak var textImage: UIImageView!
    
    @IBOutlet weak var textMessage: UILabel!
    
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var dateSentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
