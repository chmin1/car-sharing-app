
//  ProfileViewController.swift
//  CarSharingApp
//
//  Created by Elan Halpern on 7/19/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import UIKit
import Parse

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate { //UITableViewDataSource {
    
    @IBOutlet weak var profileButton: UIBarButtonItem!
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tripsTableView: UITableView!
    var newProfPic: UIImage?
    @IBOutlet weak var mySegmentedControl: UISegmentedControl!
    let list1: [String] = ["hi", "yo"]
    let list2: [String] = ["annbel", "strauss"]
    var user: PFUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //make bar button items in nav bar white
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        tripsTableView.delegate = self

        //for hamburger menu
        if self.revealViewController() != nil {
            profileButton.target = self.revealViewController()
            profileButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        if user == nil {
            user = PFUser.current()
        }
        
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
    
    @IBAction func didTapProfilePic(_ sender: Any) {
        choosePhoto()
    }

    /*
     * This is the delegate method for image picker for choosing a prof pic
     * This calls the method to get the new pic and then SAVES in background
     */
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        // Get the image captured by the UIImagePickerController
        let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        // Do something with the images (based on your use case)
        newProfPic = editedImage
        
        //uploads the new prof pic to the cloud
        let portrait = User.getPFFileFromImage(image: newProfPic)
        PFUser.current()?["profPic"] = portrait
        PFUser.current()?.saveInBackground()
        
        // Dismiss UIImagePickerController to go back to your original view controller
        dismiss(animated: true, completion: nil)
    }
    
    /*
     * This is also for choosing a prof pic
     */
    func choosePhoto() {
        // Instantiate a UIImagePickerController
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        
        //allow user to pick between photo library or camera
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {
            action in
            vc.sourceType = .camera
            self.present(vc, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {
            action in
            vc.sourceType = .photoLibrary
            self.present(vc, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        //Present the camera or photo library depending on what the user picked
        self.present(alert, animated: true, completion: nil)
    }//close choosePhoto
    

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
