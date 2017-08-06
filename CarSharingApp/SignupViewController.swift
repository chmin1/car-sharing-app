//
//  SignupViewController.swift
//  CarSharingApp
//
//  Created by Annabel Strauss on 7/12/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController, PickCollegeViewControllerDelegate {
    
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var addSchoolLabel: UILabel?
    
    var emptyFieldAlert: UIAlertController!
    var passwordAlert: UIAlertController!
    var emailAlert: UIAlertController!
    var emailDoesNotMatchSchoolAlert: UIAlertController!
    
    
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
        
        // Set up the emailAlert
        emailAlert = UIAlertController(title: "Invalid email", message: "Make sure your email is valid and that you are using a .edu email address", preferredStyle: .alert)
        emailAlert.addAction(cancelAction) // add the cancel action to the alertController
        
        // Set up the emailDoesNotMatchSchoolAlert
        emailDoesNotMatchSchoolAlert = UIAlertController(title: "Email/School mismatch", message: "Your email does not match your school's email", preferredStyle: .alert)
        emailDoesNotMatchSchoolAlert.addAction(cancelAction) // add the cancel action to the alertController
        
        //padding on textfields
        firstnameTextField.setLeftPaddingPoints(10)
        lastnameTextField.setLeftPaddingPoints(10)
        emailTextField.setLeftPaddingPoints(10)
        passwordTextField.setLeftPaddingPoints(10)
        confirmPasswordTextField.setLeftPaddingPoints(10)
    }
    
    
    
    /*
     * Tells the PickCollegeViewController that it's coming, and sets the delegate!!!! 
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "SegueToSchoolList") {
            
            let nav = segue.destination as! UINavigationController
            let vc = nav.topViewController as! PickCollegeViewController   
            vc.delegate = self
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onKeyboardDismiss(_ sender: Any) {
        view.endEditing(true)
    }
    
    
    @IBAction func didTapSubmit(_ sender: Any) {
    
        //display error message if one of the field is empty
        if allFieldsFilled() == false {
            present(emptyFieldAlert, animated: true) { }
            return
        }
        
        //display error message if passwords don't match
        if passwordTextField.text != confirmPasswordTextField.text {
            present(passwordAlert, animated: true) { }
            return
        }
        
        //display error message if email isn't valid (needs something@something.edu)
        if self.isValidEmail(testStr: emailTextField.text!) == false {
            present(emailAlert, animated: true) { }
            return
        }
        
        //display error message if email and school don't match up properly
        if self.checkEmailMatchesSchool() == false {
            present(emailDoesNotMatchSchoolAlert, animated: true) { }
            return
        }
    
        User.registerUser(image: #imageLiteral(resourceName: "profile"), withEmail: emailTextField.text, withFirstName: firstnameTextField.text, withLastName: lastnameTextField.text, withPassword: passwordTextField.text, withSchool: addSchoolLabel?.text) { (success: Bool, error: Error?) in
            if let error = error {
                print("😢 User sign up failed: \(error.localizedDescription)")
            } else if success {
                print("😃 User was created!")
                print(self.addSchoolLabel?.text ?? "default")
                // display view controller that needs to shown after successful signup
                self.performSegue(withIdentifier: "finishedSignup", sender: nil)
            }
        }
        
    }//close didTapSubmit
    
    /*
    * Check that all text fields are filled out
    */
    func allFieldsFilled() -> Bool {
        if (firstnameTextField.text?.isEmpty)! || (lastnameTextField.text?.isEmpty)! || (emailTextField.text?.isEmpty)! || (passwordTextField.text?.isEmpty)! || (confirmPasswordTextField.text?.isEmpty)! {
            return false
        }
        return true
    }
    
    /*
     * Check that email is valid
     */
    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.edu"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    /*
     * Gets the domain of the inputted email address
     */
    func getDomain(s: String) -> String {
        var v = s.components(separatedBy: "@").last?.components(separatedBy: ".")
        v?.removeLast()
        
        return (v!.last)!
    }
    
    /*
     * Checks that the uesr's email address matches the user's schools domain
     */
    func checkEmailMatchesSchool() -> Bool{
        let userDomain = self.getDomain(s: emailTextField.text!).lowercased()
        print("User domain: \(userDomain)")
        let libraryDomain = CollegesDict.collegeDict[(addSchoolLabel?.text!)!]
        if userDomain == libraryDomain{
            return true
        } else {
            return false
        }
    }
    
    /*
     * When we clicked the cell in the other class, the delegate told THIS to run
     * This gets the school from the PickCollegeViewController and sets the label in this class
     */
    func selectCollege(_ selectCollege: PickCollegeViewController, didSelectCollege college: String?) {
        addSchoolLabel?.textColor = UIColor.white
        addSchoolLabel?.text = college
    }
    
    
    
    
    
    
}//close class
