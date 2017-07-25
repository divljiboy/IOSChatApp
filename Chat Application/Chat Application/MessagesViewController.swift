//
//  MessagesViewController.swift
//  Chat Application
//
//  Created by Ivan Divljak on 7/18/17.
//  Copyright © 2017 Ivan Divljak. All rights reserved.
//

import UIKit
import Firebase

class MessagesTableViewController: UIViewController,UITextViewDelegate{
    
    
    @IBOutlet weak var sendText: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    let messagesDao = MessagesDao()
    var messagesList = [Message]()
    var defaultFrame: CGRect!
    
    
    var selectedChatroom: Chatroom = Chatroom()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        messagesDao.getMessages(chatRoom: selectedChatroom)
        messagesDao.delegate = self
        tableView.separatorStyle = .none
        defaultFrame = self.view.frame
        sendText.delegate = self
        self.hideKeyboardWhenTappedAround()
        
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyBoardWillShow),name:
            NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyBoardWillHide),name:
            NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
    }
    
    func textViewShouldReturn(textView: UITextView!) -> Bool {
        sendText.resignFirstResponder()
        return true;
    }
    func moveViewWithKeyboard(height: CGFloat) {
        self.view.frame = defaultFrame.offsetBy(dx: 0, dy: height)
    }
    
    
    func keyBoardWillHide(notification: NSNotification) {
          moveViewWithKeyboard(height: 0)
        
    }
    func keyBoardWillShow(notification: NSNotification) {
        
         let frame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
         moveViewWithKeyboard(height: -frame.height)
    }
    
    @IBAction func sendButtonClicked(_ sender: UIButton) {
        
        guard let editNameField = sendText.text else {
            return
        }
        let message = Message(name: editNameField)
        messagesDao.write(message: message, chatroom: selectedChatroom)
        sendText.text = ""
        
    }
    
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
extension MessagesTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return messagesList.count
        
    }
    
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        if Auth.auth().currentUser?.uid == messagesList[indexPath.row].client?.id{
            
            guard let cell = tableView.dequeueReusableCell( withIdentifier: "incommingCell", for: indexPath) as? MessagesTableViewCell else {
                return UITableViewCell()
            }
            cell.setupCellWithincomming(message : messagesList[indexPath.row])
            return cell
            
        }else
        {
            guard let cell = tableView.dequeueReusableCell( withIdentifier: "outgoingCell", for: indexPath) as? MessagesTableViewCell else {
                return UITableViewCell()
            }
              cell.setupCellWithoutgoing(message : messagesList[indexPath.row])
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
   func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}


extension MessagesTableViewController: MessageDaoDelegate {
    
    func loaded(messages: [Message]) {
        
        messagesList = messages
        tableView.reloadData()
    }
    
    
}
