//
//  MessagesViewController.swift
//  Chat Application
//
//  Created by Ivan Divljak on 7/18/17.
//  Copyright © 2017 Ivan Divljak. All rights reserved.
//

import UIKit
import Firebase

class MessagesViewController: UIViewController {
    
    
    @IBOutlet weak var sendText: UITextView!
    
    @IBOutlet weak var sendButton: UIButton!
    let messagesDao = MessagesDao()
    var messagesList = [Message]()
    
    var selectedChatroom: Chatroom = Chatroom()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        messagesDao.getMessages(chatRoom: selectedChatroom)
        messagesDao.delegate = self
        
       
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
      
    }
    
    @IBAction func sendButtonClicked(_ sender: UIButton) {
        
        guard let editNameField = sendText.text else {
            return
        }
        let message = Message(name: editNameField)
        messagesDao.write(message: message, chatroom: selectedChatroom)
        
    }
  
}


extension MessagesViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return messagesList.count
        
    }
    
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        if Auth.auth().currentUser?.uid == messagesList[indexPath.row].client?.id{
            
            let cell = tableView.dequeueReusableCell( withIdentifier: "incommingCell", for: indexPath) as! MessagesTableViewCell
           cell.setupCellWith(message : messagesList[indexPath.row])
            return cell
        }else
        {
            let cell = tableView.dequeueReusableCell( withIdentifier: "outgoingCell", for: indexPath) as! MessagesTableViewCell
            cell.setupCellWith(message : messagesList[indexPath.row])
            return cell
        }
        
    }
    
    
    
}


extension MessagesViewController: MessageDaoDelegate {
    
    func loaded(messages: [Message]) {
        
        messagesList = messages
        tableView.reloadData()
    }
    
    
}
