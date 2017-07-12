//
//  SignupViewController.swift
//  CarSharingApp
//
//  Created by Annabel Strauss on 7/12/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController {
    
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var collegeTextField: UITextField!
    var emptyFieldAlert: UIAlertController!
    var passwordAlert: UIAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the emptyFieldAlert
        emptyFieldAlert = UIAlertController(title: "Empty Field", message: "Fill in all text fields!", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
            // handle cancel response here. Doing nothing will dismiss the view.
        }
        emptyFieldAlert.addAction(cancelAction) // add the cancel action to the alertController
        
        // Set up the passwordAlert
        passwordAlert = UIAlertController(title: "Password mismatch", message: "Make sure your passwords match", preferredStyle: .alert)
        passwordAlert.addAction(cancelAction) // add the cancel action to the alertController
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapSubmit(_ sender: Any) {
    
        //check to display error message if one of the field is empty
        if allFieldsFilled() == false {
            present(emptyFieldAlert, animated: true) { }
            return
        }
        
        if passwordTextField.text != confirmPasswordTextField.text {
            present(passwordAlert, animated: true) { }
            return
        }
        
        User.registerUser(image: #imageLiteral(resourceName: "profile"), withEmail: emailTextField.text, withFirstName: firstnameTextField.text, withLastName: lastnameTextField.text, withPassword: passwordTextField.text, withSchool: collegeTextField.text) { (success: Bool, error: Error?) in
            if let error = error {
                print("😢 User sign up failed: \(error.localizedDescription)")
            } else {
                print("😃 User was created!")
                // display view controller that needs to shown after successful signup
                self.performSegue(withIdentifier: "finishedSignup", sender: nil)
            }
        }
        
    }//close didTapSubmit
    
    /*
    * Check that all text fields are filled out
    */
    func allFieldsFilled() -> Bool {
        if (firstnameTextField.text?.isEmpty)! || (lastnameTextField.text?.isEmpty)! || (emailTextField.text?.isEmpty)! || (passwordTextField.text?.isEmpty)! || (confirmPasswordTextField.text?.isEmpty)! || (collegeTextField.text?.isEmpty)! {
            return false
        }
        return true
    }
    
    /*
     * Find the domain of the college that the User entered
     */
    func findDomain(college: String?) {
        
    }
    
    
    
    
    
    
    
    
    
}//close class
