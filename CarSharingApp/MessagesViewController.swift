//
//  MessagesViewController.swift
//  CarSharingApp
//
//  Created by Annabel Strauss on 7/13/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import UIKit

class MessagesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var messagesView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        messagesView.delegate = self
        messagesView.dataSource = self
        
        let layout = messagesView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = layout.minimumInteritemSpacing
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let item = messagesView.dequeueReusableCell(withReuseIdentifier: "messageCell", for: indexPath) as! messagesCell
        
        item.messageTitleLabel.text = "Test"
        item.messagePreviewLabel.text = "This is a test that to check if this label works!"
        item.recipientImage.image = UIImage(named: "profile")
        
        return item
        
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
