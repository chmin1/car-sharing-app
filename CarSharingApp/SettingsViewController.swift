//
//  SettingsViewController.swift
//  CarSharingApp
//
//  Created by Annabel Strauss on 7/19/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var profileButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //for hamburger menu
        if self.revealViewController() != nil {
            profileButton.target = self.revealViewController()
            profileButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        //change color of Nav bar
        let myColor = UIColor(red: 254.0/255.0, green: 104.0/255.0, blue: 106.0/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = myColor

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func didTapBack(_ sender: Any) {
        print("hello")
        self.dismiss(animated: true) { 
            print("done")
        }
    }
    
}
