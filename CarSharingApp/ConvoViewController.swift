//
//  ConvoViewController.swift
//  CarSharingApp
//
//  Created by Chavane Minto on 7/18/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import UIKit
import Parse

class ConvoViewController: UIViewController, UITextViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var convoView: UICollectionView!
    
    @IBOutlet weak var Dock: UIView!
    
    @IBOutlet weak var messageField: UITextView!
    
    @IBOutlet weak var sendButton: UIButton!
    
    var Trip: PFObject!
    
    var previousRect: CGRect!
    var returnPressed: Int = 0
    var newLine: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        convoView.delegate = self
        convoView.dataSource = self
        messageField.delegate = self
        
        previousRect = CGRect.zero
        messageField.layer.masksToBounds = true
        messageField.layer.borderWidth = 1.0
        messageField.layer.borderColor = UIColor.black.cgColor
        messageField.layer.cornerRadius = 6
        messageField.textColor = UIColor.lightGray
        messageField.text = "Compose a message..."

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
    
    // ================ TEXTVIEW BEGIN EDIT ========================
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            returnPressed += 1
            if returnPressed < 17 {
                messageField.frame = CGRect(x: 10, y: 10, width: messageField.frame.size.width, height: messageField.frame.size.height + 17)
                newLine = 17 * returnPressed
                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                    self.Dock.transform = CGAffineTransform(translationX: 0, y: CGFloat(-208 - self.newLine))
                })
            }
        }
        
        return true
    }
    
//    func textViewDidChange(_ textView: UITextView) {
//        
//        let pos: UITextPosition? = messageField.endOfDocument
//        let currentRect: CGRect = messageField.caretRect(for: pos!)
//        if currentRect.origin.y > previousRect.origin.y || (messageField.text == "\n") {
//            returnPressed += 1
//            if returnPressed < 3 {
//                messageField.frame = CGRect(x: 5, y: 5, width: messageField.frame.size.width, height: messageField.frame.size.height + 17)
//                newLine = 17 * returnPressed
//                UIView.animate(withDuration: 0.1, animations: { () -> Void in
//                    self.Dock.transform = CGAffineTransform(translationX: 0, y: CGFloat(-208 - self.newLine))
//                })
//            }
//        }
//        
//        previousRect = currentRect
//        
//    }
//    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if (messageField.text == "") || (messageField.text == "Compose a message...") {
            messageField.text = ""
        }
        messageField.textColor = UIColor.black
        UIView.animate(withDuration: 0.209, animations: { () -> Void in
            self.Dock.transform = CGAffineTransform(translationX: 0, y: CGFloat(-208 - self.newLine))
        }, completion: { (_ finished: Bool) -> Void in
        })
        
        return true
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch: UITouch? = touches.first
        if touch?.phase == .began {
            messageField.resignFirstResponder()
            view.endEditing(true)
            let height: Int = returnPressed * 20
            UIView.animate(withDuration: 0.209, animations: { () -> Void in
                self.Dock.transform = CGAffineTransform(translationX: 0, y: CGFloat(-height))
            })
            
            if (messageField.text == "") {
                
                messageField.textColor = UIColor.lightGray
                messageField.text = "Compose a message..."
                
            }
            
        }
        
    }
    
    // ================ TEXTVIEW END EDIT ==========================
    
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
        let height: Int = returnPressed * 20
        UIView.animate(withDuration: 0.209, animations: { () -> Void in
            self.Dock.transform = CGAffineTransform(translationX: 0, y: CGFloat(-height))
        })
        
        if (messageField.text == "") {
            
            messageField.textColor = UIColor.lightGray
            messageField.text = "Compose a message..."
            
        }
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
