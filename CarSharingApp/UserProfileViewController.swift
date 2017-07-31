//
//  UserProfileViewController.swift
//  CarSharingApp
//
//  Created by Annabel Strauss on 7/31/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import UIKit
import Parse

class UserProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate { //UITableViewDataSource {
    
    
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mySegmentedControl: UISegmentedControl!
    @IBOutlet weak var tripsTableView: UITableView!
    let list1: [String] = ["hi", "yo"]
    let list2: [String] = ["annbel", "strauss"]
    var user: PFUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //make bar button items in nav bar white
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        tripsTableView.delegate = self
        
        //make prof pic circular
        profilePicImageView.layer.cornerRadius = profilePicImageView.frame.size.width / 2
        profilePicImageView.clipsToBounds = true
        
        //set name label
        let nameText = user["fullname"] as! String
        nameLabel.text = nameText.capitalized
        
        //set background and text color of Nav bar
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = Helper.coral()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //set prof pic
        if let profPic = user["profPic"] as? PFFile {
            profPic.getDataInBackground { (imageData: Data!, error: Error?) in
                self.profilePicImageView.image = UIImage(data: imageData)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var returnVal = 0
        switch(mySegmentedControl.selectedSegmentIndex)
        {
        case 0:
            returnVal = list1.count
            break
        case 1:
            returnVal = list2.count
            break
        default:
            break
        }
        
        return returnVal
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myCell = tripsTableView.dequeueReusableCell(withIdentifier: "profilePageCell", for: indexPath)
        
        switch(mySegmentedControl.selectedSegmentIndex)
        {
        case 0:
            myCell.textLabel?.text = list1[indexPath.row]
            break
        case 1:
            myCell.textLabel?.text = list2[indexPath.row]
            break
        default:
            break
        }
        
        return myCell
    }
    
    @IBAction func segmentedControlActionChanged(_ sender: Any) {
        tripsTableView.reloadData()
    }
    
    
}
