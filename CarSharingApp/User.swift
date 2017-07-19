//
//  User.swift
//  CarSharingApp
//
//  Created by Annabel Strauss on 7/11/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import UIKit
import Parse

class User: NSObject {

    class func registerUser(image: UIImage?, withEmail email: String?, withFirstName firstname: String?, withLastName lastname: String?, withPassword password: String?, withSchool school: String?, withCompletion completion: PFBooleanResultBlock?) {
        
        //create User PFUser
        let newUser = PFUser()
        newUser.password = password
        newUser.username = email
        newUser.email = email
        newUser["firstname"] = firstname
        newUser["lastname"] = lastname
        newUser["fullname"] = firstname! + " " + lastname!
        newUser["school"] = school
        newUser["profPic"] = User.getPFFileFromImage(image: #imageLiteral(resourceName: "profile"))
        newUser["myTrips"] = [PFObject]()
        
        newUser.signUpInBackground { (success: Bool, error: Error?) in
            if success {
                print("Yay, created a user!")
                //self.performSegue(withIdentifier: "loginSegue", sender: nil)
            } else {
                print(error?.localizedDescription)
            }
        }
        
    }//close registerUser
    
    /**
     Method to convert UIImage to PFFile
     - parameter image: Image that the user wants to upload to parse
     - returns: PFFile for the the data in the image
     */
    class func getPFFileFromImage(image: UIImage?) -> PFFile? {
        //check if image is not nil
        if var image = image {
            //resize image
            image = resize(image: image, newSize: CGSize(width: 1000, height: 1000))
            //get image data and check if that is not nil
            if let imageData = UIImagePNGRepresentation(image) {
                return PFFile(name: "image.png", data: imageData)
            }
        }
        return nil
    }//close getPFFileFromImage function
    
    class func resize(image: UIImage, newSize: CGSize) -> UIImage {
        let resizeImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        resizeImageView.contentMode = UIViewContentMode.scaleAspectFill
        resizeImageView.image = image
        
        UIGraphicsBeginImageContext(resizeImageView.frame.size)
        resizeImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    
}//close class
