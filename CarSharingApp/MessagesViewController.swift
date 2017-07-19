//
//  MessagesViewController.swift
//  CarSharingApp
//
//  Created by Annabel Strauss on 7/13/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import UIKit
import Parse

class MessagesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var messagesView: UICollectionView!
    
    var tripData: [PFObject?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        messagesView.delegate = self
        messagesView.dataSource = self
        refresh()
        
        let layout = messagesView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = layout.minimumInteritemSpacing
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tripData.count 
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let item = messagesView.dequeueReusableCell(withReuseIdentifier: "messageCell", for: indexPath) as! messagesCell
        let trip = tripData[indexPath.row]
        item.messageTitleLabel.text = trip?["Name"] as? String ?? "No name trip"
        item.messagePreviewLabel.text = "This is a test that to check if this label works!"
        item.recipientImage.image = UIImage(named: "profile")
        item.hasReadImage.image = UIImage(named: "profile")
        
        return item
        
    }
    
    func refresh() {
        let query = PFQuery(className: "Trip")
        query.includeKey("Planner")
        //query.whereKey("Planner", equalTo: PFUser.current())
        //query.order(byDescending: "_created_at")
        query.findObjectsInBackground { (trips: [PFObject]?, error: Error?) in
            if let trips = trips {
                // do something with the array of object returned by the call
                self.tripData.removeAll()
                for trip in trips {
                    self.tripData.append(trip)
                }
                
                self.messagesView.reloadData()
                //self.refreshControl.endRefreshing()
            } else {
                print(error?.localizedDescription)
            }
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Segues current trip info to the convo view controller
        
        // Get the UICollectionViewCell
        let item = sender as! UICollectionViewCell
        
        if let indexPath = messagesView.indexPath(for: item) {
            
            let trip = tripData[indexPath.row]
            
            //Get the segue destination
            let dest = segue.destination as! ConvoViewController
            
            //pass the info from the cell to the trip
            dest.Trip = trip
            
        }
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    */

}
