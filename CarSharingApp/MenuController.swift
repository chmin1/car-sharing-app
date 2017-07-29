//
//  MenuController.swift
//  CarSharingApp
//
//  Created by Annabel Strauss on 7/19/17.
//  Copyright © 2017 FBU. All rights reserved.
//
//  https://github.com/John-Lluch/SWRevealViewController
//

import UIKit
import Parse

class MenuController: UITableViewController {

    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //make prof pic circular
        profilePicImageView.layer.cornerRadius = profilePicImageView.frame.size.width / 2
        profilePicImageView.clipsToBounds = true
        
        //set name label
        let nameText = PFUser.current()?["fullname"] as! String
        nameLabel.text = nameText.capitalized
        
        //no lines between table view cells
        self.tableView.separatorStyle = .none
        
    }

    override func viewWillAppear(_ animated: Bool) {
        //set prof pic
        if let profPic = PFUser.current()?["profPic"] as? PFFile {
            profPic.getDataInBackground { (imageData: Data!, error: Error?) in
                self.profilePicImageView.image = UIImage(data: imageData)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapLogout(_ sender: Any) {
        //logs user out
        NotificationCenter.default.post(name: NSNotification.Name("logoutNotification"), object: nil)
        PFUser.logOutInBackground(block: { (error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Successful loggout")
            }
        })
    }



}
