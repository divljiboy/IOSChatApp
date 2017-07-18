//
//  TableViewController.swift
//  ChatApp
//
//  Created by Ivan Divljak on 7/11/17.
//  Copyright © 2017 Ivan Divljak. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class TableViewController: UIViewController,  GIDSignInUIDelegate{
    
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    
    @IBOutlet weak var signOutButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    private let userDao = UserDao()
    var chatRooms = [Chatroom]()
    
    let chatroomDao = ChatroomDao()
    var window: UIWindow?
    var deleteChatroomIndexPath: NSIndexPath? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        updateUI()
        
        chatroomDao.delegate = self
        
        (UIApplication.shared.delegate as? AppDelegate)?.SignInDelegate = updateUI
        
        (UIApplication.shared.delegate as? AppDelegate)?.SignOutDelegate = updateUI
        GIDSignIn.sharedInstance().uiDelegate = self
        
    }
    
    
    func updateUI() {
        
        if Auth.auth().currentUser != nil {
            signOutButton.isHidden = false
            tableView.isHidden = false
            
            guard let realUser = Auth.auth().currentUser ,
                let realUserName = realUser.displayName,
                let realUserEmail = realUser.email ,
                let realUserURL = realUser.photoURL?.absoluteString else {
                    return
            }
            let user = User(id: realUser.uid, name: realUserName, email: realUserEmail, url: realUserURL)
            
            userDao.write(user: user)
            chatroomDao.get()
            tableView.reloadData()
            self.navigationController?.isNavigationBarHidden = false
            
        }
        else
        {
            signOutButton.isHidden = true
            tableView.isHidden = true
            self.navigationController?.isNavigationBarHidden = true
        }
        
    }
    
    
    @IBAction func signOutAction(_ sender: UIButton) {
        
        GIDSignIn.sharedInstance().disconnect()
    }
    
    
}

extension TableViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return chatRooms.count
        
    }
    
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        
        let cell = tableView.dequeueReusableCell( withIdentifier: "tableCell", for: indexPath) as! TableViewCell
        
        cell.setupCellWith(chatroom: chatRooms[indexPath.row])
        
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "selectedConversation", sender: chatRooms[indexPath.row])
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectedConversation" {
            
            guard let selectedChatroom = sender as? Chatroom else {
                 print("Error parsing chatroom")
                 return
            }
            let controller = segue.destination as! MessagesViewController
            controller.selectedChatroom = selectedChatroom
        
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteChatroomIndexPath = indexPath as NSIndexPath
            let chatroomToDelete = chatRooms[indexPath.row]
            confirmDelete(chatroom : chatroomToDelete)
            
        }
    }
    
    func confirmDelete(chatroom : Chatroom) {
        DialogUtils.showYesNoDialog(self, choises: [("Yes",.destructive),("No",.cancel)]) { (data) in
            switch data {
            case "No":
                self.deleteChatroomIndexPath = nil
                
            case "Yes":
                
                self.chatroomDao.delete(chatroom: chatroom)
            default:
                print ("Nothing happened")
                
            }
        }
    }
    
}

extension TableViewController: ChatroomDaoDelegate {
    
    func Loaded(chatrooms: [Chatroom]) {
        
        chatRooms = chatrooms
        tableView.reloadData()
    }
    
    
}
