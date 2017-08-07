//
//  ConvoViewController.swift
//  CarSharingApp
//
//  Created by Chavane Minto on 7/18/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import UIKit
import Parse
import ParseLiveQuery
import GrowingTextView

class ConvoViewController: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var convoView: UITableView!
    
    @IBOutlet weak var Dock: UIView!
    
    @IBOutlet weak var topBorder: UIView!
    
    @IBOutlet weak var messageField: GrowingTextView!
    
    @IBOutlet weak var sendButton: UIButton!
    
    var Trip: PFObject!
    var convoMessages: [PFObject] = []
    
    var previousRect: CGRect!
    var returnPressed: Int = 0
    var newLine: Int = 0
    
    var bottomConstraint = NSLayoutConstraint()
    let keyboardBaseHeight: CGFloat = -49
    
    //Parse Live Query Client
    let liveQueryClient = ParseLiveQuery.Client()
    
    // A subscription for the live query client
    var subscriptionX:Subscription<PFObject>? = nil;
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        convoView.backgroundColor = UIColor.clear
        
        automaticallyAdjustsScrollViewInsets = false
        
        convoView.rowHeight = UITableViewAutomaticDimension
        convoView.estimatedRowHeight = 100
        convoView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        convoView.delegate = self
        convoView.dataSource = self
        messageField.delegate = self
        
        bottomConstraint = NSLayoutConstraint(item: Dock, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: keyboardBaseHeight)
        view.addConstraint(bottomConstraint)
        
        previousRect = CGRect.zero
        messageField.layer.masksToBounds = true
        messageField.maxLength = 0
        messageField.maxHeight = 100
        messageField.placeHolder = "Compose a message..."
        messageField.placeHolderColor = UIColor.white
        messageField.textColor = UIColor.white
        
        Dock.backgroundColor = Helper.coral()
        topBorder.backgroundColor = Helper.peach()
        sendButton.backgroundColor = UIColor.white
        sendButton.layer.borderWidth = 2.5
        sendButton.layer.borderColor = Helper.peach().cgColor
        sendButton.layer.cornerRadius = sendButton.frame.height / 2
        sendButton.setTitleColor(Helper.peach(), for: .normal)
        sendButton.backgroundColor = nil

        if let title = Trip["Name"] as? String {
            navigationItem.title = title
        }
        
        loadOnOpen()
        
        let amountOfLinesShown: CGFloat = 6
        let maxHeight:CGFloat = messageField.font!.lineHeight * amountOfLinesShown
        messageField.sizeThatFits(CGSize(width: 315, height: maxHeight))
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let tableViewContentHeight = convoView.contentSize.height;
        let tableViewFrameHeightAfterInserts = convoView.frame.size.height - (convoView.contentInset.top + convoView.contentInset.bottom)
        
        if(tableViewContentHeight > tableViewFrameHeightAfterInserts) {
            convoView.setContentOffset(CGPoint(x: 0, y: convoView.contentSize.height - convoView.frame.size.height), animated: false)
        }
    }
    
    // ================ TEXTVIEW BEGIN EDIT ========================
    
    func handleKeyboardNotification(notification: NSNotification) {
        
        if let userInfo = notification.userInfo{
            
            let keyBoardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            print(keyBoardFrame!)
            
            //let isKeyBoardShowing = NSNotification.Name.UIKeyboardWillShow
            
            bottomConstraint.constant = -keyBoardFrame!.height
            
            if (messageField.text == "") || (messageField.text == "Compose a message...") {
                messageField.text = ""
            }
            
            
            UIView.animate(withDuration: 0, animations: {
                
                self.view.layoutIfNeeded()
                
            }, completion: { (completion) in
                
                let indexPath = IndexPath(item: self.convoMessages.count - 1, section: 0)
                if self.convoMessages.count >= 4 {
                    self.convoView.scrollToRow(at: indexPath, at: .bottom, animated: true)

                }
                
            })
        }
        
        
        
    }
    
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        if text == "\n" {
//            returnPressed += 1
//            if returnPressed < 6 {
//                messageField.frame = CGRect(x: 10, y: 10, width: messageField.frame.size.width, height: messageField.frame.size.height + 6)
//                newLine = 6 * returnPressed
//                UIView.animate(withDuration: 0.1, animations: { () -> Void in
//                    self.Dock.transform = CGAffineTransform(translationX: 0, y: CGFloat(-165 - self.newLine))
//                    self.convoView.transform = CGAffineTransform(translationX: 0, y: CGFloat(-165 - self.newLine))
//                })
//                 
//            }
//        }
//        
//        return true
//    }
//    
//    func textViewDidChange(_ textView: UITextView) {
//
//        let pos: UITextPosition? = messageField.endOfDocument
//        let currentRect: CGRect = messageField.caretRect(for: pos!)
//        if currentRect.origin.y > previousRect.origin.y || (messageField.text == "\n") {
//            returnPressed += 1
//            if returnPressed < 6 && returnPressed > 1 {
//                messageField.frame = CGRect(x: 5, y: 5, width: messageField.frame.size.width, height: messageField.frame.size.height + 6)
//                newLine = 6 * returnPressed
//                UIView.animate(withDuration: 0.1, animations: { () -> Void in
//                    self.Dock.transform = CGAffineTransform(translationX: 0, y: CGFloat(-165 - self.newLine))
//                    self.convoView.transform = CGAffineTransform(translationX: 0, y: CGFloat(-165 - self.newLine))
//                })
//            }
//        }
//        
//        previousRect = currentRect
//        
//    }
//    
//    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
//        if (messageField.text == "") || (messageField.text == "Compose a message...") {
//            messageField.text = ""
//        }
//        messageField.textColor = UIColor.black
//        UIView.animate(withDuration: 0.209, animations: { () -> Void in
//            self.Dock.transform = CGAffineTransform(translationX: 0, y: CGFloat(-165 - self.newLine))
//            self.convoView.transform = CGAffineTransform(translationX: 0, y: CGFloat(-165 - self.newLine))
//        }, completion: { (_ finished: Bool) -> Void in
//        })
//        
//        return true
//        
//    }
//
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        
//        let touch: UITouch? = touches.first
//        if touch?.phase == .began {
//            messageField.resignFirstResponder()
//            view.endEditing(true)
//            let height: Int = returnPressed * 20
//            UIView.animate(withDuration: 0.209, animations: { () -> Void in
//                self.Dock.transform = CGAffineTransform(translationX: 0, y: CGFloat(-height))
//                self.convoView.transform = CGAffineTransform(translationX: 0, y: CGFloat(-height))
//            })
//            
//            if (messageField.text == "") {
//                
//                messageField.textColor = UIColor.lightGray
//                messageField.text = "Compose a message..."
//                
//            }
//            
//        }
//        
//    }
    
    // ================ TEXTVIEW END EDIT ==========================
    
    // ================ LOAD MESSAGES ON OPEN ======================
    
    func loadOnOpen() {
        let currentUser = PFUser.current()!
        //Query the message object/clas in parse
        let query = PFQuery(className: "Message")
        
        //Query messages based on Trip ID
        let tripID = Trip.objectId!
        query.whereKey("TripID", equalTo: tripID)
        
        //Order by oldest messages on top
        query.order(byAscending: "_created_at")
        
        // Find messages associated with this trip
        query.findObjectsInBackground { (messages: [PFObject]?, error: Error?) in
            if let messages = messages {
                // Add messages to the global ist of messages, then reload the view so it can be displayed
                for message in messages {
                    
                    self.convoMessages.append(message)
                    
                }
                
                self.convoView.reloadData()
            } else {
                print(error?.localizedDescription ?? "oops")
            }
            
        }
        
        //Subscribe the parse user to the live query
        self.subscriptionX = self.liveQueryClient
            .subscribe(query);
        
        self.subscriptionX?.handle(Event.created) { _, message in
            
            self.convoMessages.append(message)
            self.convoView.reloadData()
        }
    }
    
    // ================ LOAD MESSAGES ON OPEN ======================
    
    // ================ LOAD COLLECTIONVIEW ========================
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return convoMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = convoView.dequeueReusableCell(withIdentifier: "ConvoCell", for: indexPath) as! ConvoCell
        //let item = convoView.dequeueReusableCell(withIdentifier: "convoCell", for: indexPath) as! ConvoCell
        let message = convoMessages[indexPath.row]
        
        let messageText: String
        let author: String
        let date: String
        do {
            try message.fetchIfNeededInBackground()
            
            if let _messageText = message["Text"] as? String {
                
                messageText = _messageText
                
            } else {
                
                messageText = "Failed to load the message"
                
            }
            
            if let _author = message["Author"] as? String {
                
                author = _author
                
            } else {
                
                author = "Failed to load author"
                
            }
            
            if let _date = message["dateSent"] as? String {
                date = _date
            } else {
                
                date = "Failed to load"
                
            }
            
        } catch {
            messageText = "Failed to load the message"
            author = "Failed to load author"
            date = "Failed to load"
            
        }
        
        var profilePic: PFFile!
        
        if let tripMembers = Trip["Members"] as? [PFUser] {
            for member in tripMembers {
                if let fullName = member["fullname"] as? String {
                    if (fullName == author) {
                        profilePic = member["profPic"] as! PFFile
                    }
                }
            }
        }
        
        profilePic.getDataInBackground { (data: Data?, error: Error?) in
            item.textImage.image = UIImage(data: data!)
        }
        
        item.textMessage.text = messageText
        let size = CGSize(width: 250, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12)], context: nil)
        item.textMessage.frame = CGRect(x: 0, y: 0, width: estimatedFrame.width, height: estimatedFrame.height)
        
        item.authorLabel.text = author
        
        if author == PFUser.current()?["fullname"] as! String {
            item.textBubble.backgroundColor = Helper.peach()
        } else {
            item.textBubble.backgroundColor = Helper.veryLightGray()
        }
        
        item.dateSentLabel.text = date
        
        return item
    }
    

    

    
    // ================ LOAD COLLECTIONVIEW ========================
    
    // ============== POST AND RETRIEVE MESSAGE ====================
    
    @IBAction func onSendMessage(_ sender: Any) {
        
        var author: String = ""
        if let _author = PFUser.current()?["fullname"] as? String {
            
            author = _author
            
        }
        
        let textMessage = messageField.text
        let tripID = Trip.objectId
        
        let date = Date()
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.timeZone = NSTimeZone.local
        
        let localDate = dateFormatter.string(from: date)
        
        message.postMessage(withMessageText: textMessage, withAuthor: author, withDateSent: localDate, withTripID: tripID) { (message: PFObject?, error: Error?) in
            if let error = error {
                print(error.localizedDescription)
            } else if let message = message {
                var tripMessages = self.convoMessages
                tripMessages.append(message)
                //self.convoMessages = tripMessages
                self.Trip["Messages"] = tripMessages
                self.Trip.saveInBackground()
                print("Saved Successfully 📝")
                
                self.messageField.text = ""
                
                self.convoView.reloadData()
            }
        }
        
        
        
    }
    
    // ============== POST AND RETRIEVE MESSAGE ====================
    
    // ===================== DISMISS KEYBOARD ======================
    @IBAction func onScreenTap(_ sender: Any) {
        view.endEditing(true)
//        let height: Int = returnPressed * 20
//        UIView.animate(withDuration: 0.209, animations: { () -> Void in
//            self.Dock.transform = CGAffineTransform(translationX: 0, y: CGFloat(-height))
//        })
        
        bottomConstraint.constant = -49
        
        UIView.animate(withDuration: 0, animations: {
            
            self.view.layoutIfNeeded()
            
        }, completion: { (completion) in
            
            let indexPath = IndexPath(item: self.convoMessages.count - 1, section: 0)
            self.convoView.scrollToRow(at: indexPath, at: .bottom, animated: true)

            
        })
        
    }
    // ===================== DISMISS KEYBOARD ======================

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
