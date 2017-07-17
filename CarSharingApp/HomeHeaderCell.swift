//
//  HomeHeaderCell.swift
//  CarSharingApp
//
//  Created by Elan Halpern on 7/12/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import UIKit

protocol HomeHeaderCellDelegate: class {
    func HomeHeaderCell(_ homeHeaderCell: HomeHeaderCell, didTap label: UILabel)
}


class HomeHeaderCell: UITableViewCell {
    
    @IBOutlet weak var startTextLabel: UILabel!
    
    @IBOutlet weak var endTextLabel: UILabel!
    
    weak var delegate: HomeHeaderCellDelegate?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        let startLabelTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapStartLabel(_sender:))
        )
        let endLabelTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapEndLabel(_sender:))
        )
        startTextLabel.layer.borderColor = UIColor.gray.cgColor
        startTextLabel.layer.borderWidth = 0.5
        startTextLabel.addGestureRecognizer(startLabelTapGestureRecognizer)
        startTextLabel.isUserInteractionEnabled = true
        
        endTextLabel.layer.borderColor = UIColor.gray.cgColor
        endTextLabel.layer.borderWidth = 0.5
        endTextLabel.addGestureRecognizer(endLabelTapGestureRecognizer)
        endTextLabel.isUserInteractionEnabled = true
    
    }

    
    
    
    func didTapStartLabel(_sender: UITapGestureRecognizer) {
        delegate?.HomeHeaderCell(self, didTap: startTextLabel)
        print("Tapped start label")
    }
    
    func didTapEndLabel(_sender: UITapGestureRecognizer) {
        delegate?.HomeHeaderCell(self, didTap: endTextLabel)
        print("Tapped End label")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
