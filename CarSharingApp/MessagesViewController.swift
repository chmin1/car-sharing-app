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
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messagesView.delegate = self
        messagesView.dataSource = self
        refresh()
        
        //Initialize a Refresh Control
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        // add refresh control to table view
        messagesView.insertSubview(refreshControl, at: 0)
        messagesView.alwaysBounceVertical = true
        
        let layout = messagesView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = layout.minimumInteritemSpacing
        
    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        refresh()
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
        
        return item
        
    }
    
    func refresh() {
        let currentUser = PFUser.current()
        let query = PFQuery(className: "Trip")
        query.includeKey("Name")
        query.includeKey("Members")
        query.whereKey("Members", equalTo: currentUser!)
        query.findObjectsInBackground { (trips: [PFObject]?, error: Error?) in
            if let trips = trips {
                self.tripData.removeAll()
                for trip in trips {
                    if let tripEditId = trip["EditID"] as? String { //get EditID so that the trip won't show if it's an edit
                        if(tripEditId != "-1"){ //only add trip to the feed if it's NOT an edit
                            self.tripData.append(trip)
                        } else {
                            print(error?.localizedDescription)
                        }
                    }
                    
                }
                self.messagesView.reloadData()
                self.refreshControl.endRefreshing()
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
            print(trip!)
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
