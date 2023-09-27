//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    @IBOutlet weak var logOutPressed: UIBarButtonItem!
    
    let db = Firestore.firestore()
    
    var messages: [Message] = []
    var listener: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowUp), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowDown), name: UIResponder.keyboardWillHideNotification, object: nil)
        tableView.dataSource = self
        title = K.appName
        navigationItem.hidesBackButton = true
        
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        
        startListeningForMessages()
    }
    
    @objc func keyboardWillShowUp(notification: Notification) {
        if let userInfo = notification.userInfo,
                let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                
                
                let keyboardHeight = keyboardFrame.height
            
                tableView.contentInset.top = keyboardHeight
            }
    }

    @objc func keyboardWillShowDown(notification: Notification) {
        tableView.contentInset.top = 0
        
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        let lastIndexPath = IndexPath(row: self.messages.count - 1, section: 0)
        tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
    }
    
    func startListeningForMessages() {
        listener = db.collection(K.FStore.collectionName)
            .order(by: K.FStore.dateField)
            .addSnapshotListener { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }

                self.messages = documents.compactMap { document in
                    let data = document.data()
                    if let sender = data[K.FStore.senderField] as? String,
                        let messageBody = data[K.FStore.bodyField] as? String {
                        return Message(sender: sender, body: messageBody)
                    }
                    return nil
                }
            
                self.tableView.reloadData()
                let lastIndexPath = IndexPath(row: self.messages.count - 1, section: 0)
                self.tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
            }
    }
    
    deinit {
        listener?.remove()
    }
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        do {
          try Auth.auth().signOut()
          navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
    }
    
    
    @IBAction func sendPressed(_ sender: UIButton) {
        if let messageBody = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email {
            let timestamp = FieldValue.serverTimestamp()
            
            db.collection(K.FStore.collectionName).addDocument(data: [K.FStore.senderField: messageSender, K.FStore.bodyField: messageBody, K.FStore.dateField: timestamp]) { (error) in
                if let err = error {
                    print("There was an issue saving data to firestore, \(err)")
                } else {
                    print("Successfully saved data.")
                    
                    DispatchQueue.main.async {
                        self.messageTextfield.text = ""
                    }
                }
            }
        }
    }
    

}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        cell.label.text = message.body
        
        if message.sender == Auth.auth().currentUser?.email {
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
            cell.label.textColor = UIColor(named: K.BrandColors.purple)
        } else {
            cell.leftImageView.isHidden = false
            cell.rightImageView.isHidden = true
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.purple)
            cell.label.textColor = UIColor(named: K.BrandColors.lightPurple)
        }
        
        return cell
    }
}

