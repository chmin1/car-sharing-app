//
//  CreateConvoViewController.swift
//  CarSharingApp
//
//  Created by Chavane Minto on 7/18/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import UIKit

class CreateConvoViewController: UIViewController {
    
    // THIS IS A DUMMY CLASS THAT WILL BE DELETED LATER ALONG WITH ITS VIEW CONTROLLER *****
    // THIS CLASS IS FOR TESTING PURPOSES ONLY *********************************************
    
    @IBOutlet weak var Rider1Field: UITextField!
    
    @IBOutlet weak var Rider2Field: UITextField!
    
    @IBOutlet weak var Rider3Field: UITextField!
    
    @IBOutlet weak var Rider4Field: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func onScreenTap(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func onSubmitConvo(_ sender: Any) {
        
    }
    
    @IBAction func onDismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
