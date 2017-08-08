//
//  MessagesViewController.swift
//  CarSharingApp
//
//  Created by Annabel Strauss on 7/13/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import UIKit
import Parse
import ParseLiveQuery

class MessagesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var messagesView: UICollectionView!
    
    @IBOutlet weak var emojiView: UIImageView!
    var tripData: [PFObject?] = []
    var tripIDs: [String] = []
    
    var refreshControl: UIRefreshControl!
    
    //Parse Live Query Client
    let liveQueryClient = ParseLiveQuery.Client()
    
    // A subscription for the live query client
    var subscriptionX:Subscription<PFObject>? = nil;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emojiView.isHidden = true
        
        //make bar button items in nav bar white
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        messagesView.delegate = self
        messagesView.dataSource = self
        refresh()
        getMessageTripIDs()
        
        //Initialize a Refresh Control
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        // add refresh control to table view
        messagesView.insertSubview(refreshControl, at: 0)
        messagesView.alwaysBounceVertical = true
        
        let layout = messagesView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = layout.minimumInteritemSpacing
        
        //set background and text color of Nav bar
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = Helper.coral()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        refresh()
        getMessageTripIDs()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tripData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        
        let item = messagesView.dequeueReusableCell(withReuseIdentifier: "messageCell", for: indexPath) as! messagesCell
        let trip = tripData[indexPath.row]
        do {
            try trip?.fetchIfNeeded()
            let title = trip?["Name"] as? String ?? "No name trip"
            item.messageTitleLabel.text = title.capitalized
            let createdAt = trip?.updatedAt
            let dateFormatter = DateFormatter()
            
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            dateFormatter.timeZone = NSTimeZone.local
            
            let localDate = dateFormatter.string(from: createdAt!)
            item.dateLabel.text = localDate
            
//            if let message = (trip?["Messages"] as? [PFObject])?.last {
//                do {
//                    try   message.fetchIfNeeded()
//                    if let messageText = message["Text"] as? String {
//                        item.messagePreviewLabel.text = messageText
//                    }
//                } catch {
//                    item.messagePreviewLabel.text = "Failed to fetch data"
//                }
//                
//            }
            
            var textPrev: String!
            let tripID = trip?.objectId
            if tripIDs.contains(tripID!) {
                if let tripMsgs = trip?["Messages"] as? [PFObject?] {
                    let lastMsgIndex = tripMsgs.count - 1
                    if let lastMsg = tripMsgs[lastMsgIndex] {
                        try lastMsg.fetchIfNeeded()
                        if let msgText = lastMsg["Text"] as? String {
                            textPrev = msgText
                        }
                    }
                }
            } else {
                
                textPrev = "No Messages Yet... 📝"
                
            }
            item.messagePreviewLabel.text = textPrev
            
            if let tripMembers = trip?["Members"] as? [PFUser] {
                let memberNames = Helper.returnMemberNames(tripMembers: tripMembers)
                print(memberNames)
                
                let memberProfPics = Helper.returnMemberProfPics(tripMembers: tripMembers)
                Helper.displayProfilePics(withCell: item, withMemberPics: memberProfPics)
            }
            
        } catch {
            
            item.messageTitleLabel.text = "Not Found"
            item.dateLabel.text = "Not Found"
            item.messagePreviewLabel.text = "Not Found"
            if let tripMembers = trip?["Members"] as? [PFUser] {
                let memberNames = Helper.returnMemberNames(tripMembers: tripMembers)
                print(memberNames)
                
                let memberProfPics = Helper.returnMemberProfPics(tripMembers: tripMembers)
                Helper.displayProfilePics(withCell: item, withMemberPics: memberProfPics)
            }
            
        }
        
        return item
        
    }
    
    func getMessageTripIDs() {
        
        let query = PFQuery(className: "Message")
        query.includeKey("TripID")
        do{
           let results = try query.findObjects()
            for result in results {
                if let tripID = result["TripID"] as? String {
                    if tripIDs.contains(tripID) {
                        continue
                    } else {
                        tripIDs.append(tripID)
                    }
                }
            }
        } catch {
            print("no Messages found")
        }
        
        
    }
    
    func refresh() {
        let currentUser = PFUser.current()
        let query = PFQuery(className: "Trip")
        query.includeKey("Name")
        query.includeKey("Members")
        query.includeKey("_updated_at")
        query.whereKey("Members", equalTo: currentUser!)
        query.order(byDescending: "_updated_at")
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
                
                //displays the "No trips" label if there are no trips to display
                if self.tripData.count == 0 {
                    Helper.displayEmptyCollectionView(withCollectionView: self.messagesView, withText: "No messages to display!")
                    self.emojiView.isHidden = false
                } else {
                    self.emojiView.isHidden = true
                    self.messagesView.backgroundView?.isHidden = true
                    
                }
                
                self.messagesView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
        
        //Subscribe the parse user to the live query
        self.subscriptionX = self.liveQueryClient
            .subscribe(query);
        
        self.subscriptionX?.handle(Event.created) { _, trip in
            self.tripData.append(trip)
            self.messagesView.reloadData()
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
