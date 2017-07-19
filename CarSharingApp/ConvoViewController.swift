//
//  ConvoViewController.swift
//  CarSharingApp
//
//  Created by Chavane Minto on 7/18/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import UIKit
import Parse

class ConvoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var convoView: UICollectionView!
    
    @IBOutlet weak var messageField: UITextView!
    
    var Trip: PFObject!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        convoView.delegate = self
        convoView.dataSource = self

        if let title = Trip["Name"] as? String {
            print(title)
            navigationItem.title = title
        }
        
        let id = Trip.objectId!
        print(id)
        
        let amountOfLinesShown: CGFloat = 6
        let maxHeight:CGFloat = messageField.font!.lineHeight * amountOfLinesShown
        messageField.sizeThatFits(CGSize(width: 315, height: maxHeight))
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = convoView.dequeueReusableCell(withReuseIdentifier: "convoCell", for: indexPath) as! ConvoCell
        
        item.textImage.image = UIImage(named: "profile")
        item.testMessage.text = "I am a message!"
        
        return item
    }
    
    @IBAction func onSendMessage(_ sender: Any) {
        
    }
    
    @IBAction func onScreenTap(_ sender: Any) {
        view.endEditing(true)
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
