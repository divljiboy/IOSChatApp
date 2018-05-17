//
//  MessagesViewController.swift
//  Chat Application
//
//  Created by Ivan Divljak on 7/18/17.
//  Copyright © 2017 Ivan Divljak. All rights reserved.
//

import UIKit
import Firebase
import ALTextInputBar
import CoreLocation

class MessagesTableViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let messagesDao = MessagesDao()
    let textInputBar = ALTextInputBar()
    let keyboardObserver = ALKeyboardObservingView()
    var selectedChatroom: Chatroom!
    var messagesList: [Message] = []
    let showLocationSegue = "showLocation"
    let showMapSegue = "showMap"
    
    // This is how we observe the keyboard position
    override var inputAccessoryView: UIView? {
        get {
            return keyboardObserver
        }
    }
    
    // This is also required
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureScrollView()
        configureInputBar()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        messagesDao.getMessages(chatRoom: selectedChatroom)
        messagesDao.delegate = self
        tableView.separatorStyle = .none
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameChanged(notification:)), name: NSNotification.Name(rawValue: ALKeyboardFrameDidChangeNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        textInputBar.frame.size.width = view.bounds.size.width
    }
    
    func configureScrollView() {
        tableView.keyboardDismissMode = .interactive
    }
    
    func configureInputBar() {
        let leftButton  = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        let rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        rightButton.setTitle("Send", for: .normal)
        
        leftButton.setImage(#imageLiteral(resourceName: "icons8-user-96"), for: .normal)
        
        rightButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        leftButton.addTarget(self, action: #selector(showMap), for: .touchUpInside)
        
        keyboardObserver.isUserInteractionEnabled = false
        
        textInputBar.showTextViewBorder = true
        textInputBar.leftView = leftButton
        textInputBar.rightView = rightButton
        if #available(iOS 11.0, *) {
            let guide = view.safeAreaLayoutGuide
            let height = guide.layoutFrame.size.height
             textInputBar.frame = CGRect(x: 0, y: height - textInputBar.defaultHeight, width: view.frame.size.width, height: textInputBar.defaultHeight)
        } else {
            // Fallback on earlier versions
        }
        
        textInputBar.frame = CGRect(x: 0, y: view.frame.size.height - textInputBar.defaultHeight, width: view.frame.size.width, height: textInputBar.defaultHeight)
        textInputBar.backgroundColor = UIColor(white: 0.95, alpha: 1)
        textInputBar.keyboardObserver = keyboardObserver
        
        view.addSubview(textInputBar)
    }
    
    @objc func showMap() {
        self.performSegue(withIdentifier: showMapSegue, sender: nil)
    }
    
    @objc func keyboardFrameChanged(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let frame = userInfo[UIKeyboardFrameEndUserInfoKey] as! CGRect
            textInputBar.frame.origin.y = frame.origin.y
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let frame = userInfo[UIKeyboardFrameEndUserInfoKey] as! CGRect
            textInputBar.frame.origin.y = frame.origin.y
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let frame = userInfo[UIKeyboardFrameEndUserInfoKey] as! CGRect
            textInputBar.frame.origin.y = frame.origin.y
        }
    }
    
    @objc func sendMessage() {
        guard let editNameField = textInputBar.text else {
            return
        }
        let message = Message(name: editNameField)
        messagesDao.write(message: message, chatroom: selectedChatroom)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showLocationSegue, sender: nil)
    }

}


extension MessagesTableViewController: MessageDaoDelegate {

    func loaded(messages: [Message]) {

        messagesList = messages
        tableView.reloadData()
    }

}
