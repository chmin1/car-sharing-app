//
//  LoginViewController.swift
//  CarSharingApp
//
//  Created by Annabel Strauss on 7/12/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var emptyFieldAlert: UIAlertController!
    var notAUserAlert: UIAlertController!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up the emptyFieldAlert
        emptyFieldAlert = UIAlertController(title: "Empty Field", message: "Fill in all text fields!", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
            // handle cancel response here. Doing nothing will dismiss the view.
        }
        emptyFieldAlert.addAction(cancelAction) // add the cancel action to the alertController
        
        // Set up the notAUserAlert
        notAUserAlert = UIAlertController(title: "User Not Found", message: "We can't find a user with that email or password", preferredStyle: .alert)
        notAUserAlert.addAction(cancelAction) // add the cancel action to the alertController

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapLogin(_ sender: Any) {
        
        //check to display error message if one of the field is empty
        if (usernameTextField.text?.isEmpty)! || (passwordTextField.text?.isEmpty)! {
            present(emptyFieldAlert, animated: true) { }
            return
        }
        
        let username = usernameTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        PFUser.logInWithUsername(inBackground: username, password: password) { (user: PFUser?, error: Error?) in
            if let error = error {
                self.present(self.notAUserAlert, animated: true) { }
                print("😠 User log in failed: \(error.localizedDescription)")
            } else {
                print("😀 User logged in successfully")
                // display view controller that needs to shown after successful login
                self.performSegue(withIdentifier: "finishedLogin", sender: nil)
            }
        }
        
    }//close didTapLogin


}//close class
