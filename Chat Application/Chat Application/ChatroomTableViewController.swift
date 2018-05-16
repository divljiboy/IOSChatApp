//
//  TableViewController.swift
//  ChatApp
//
//  Created by Ivan Divljak on 7/11/17.
//  Copyright © 2017 Ivan Divljak. All rights reserved.
//

import Foundation
import Firebase
import GoogleSignIn


class ChatroomTableViewController: UIViewController,  GIDSignInUIDelegate{
    
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var chatRooms = [Chatroom]()
    
    weak var appDelegate: AppDelegate!
    var window: UIWindow?
    var deleteChatroomIndexPath: NSIndexPath? = nil
    let chatroomDao = ChatroomDao()
    let userDao = UserDao()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        updateUI()
        chatroomDao.delegate = self
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        self.appDelegate = appDelegate
        appDelegate.signInDelegate = updateUI
        appDelegate.signOutDelegate = updateUI
        GIDSignIn.sharedInstance().uiDelegate = self
        
    }
    
    
    func updateUI() {
        if Auth.auth().currentUser != nil {
            signOutButton.isHidden = false
            tableView.isHidden = false
            guard let user = Auth.auth().currentUser else {
                print("Error parsing user")
                return
            }
            userDao.write(client: Client(user: user) )
            chatroomDao.get()
            tableView.reloadData()
            self.navigationController?.isNavigationBarHidden = false
        } else {
            signOutButton.isHidden = true
            tableView.isHidden = true
            self.navigationController?.isNavigationBarHidden = true
        }
    }
    
    @IBAction func signOutAction(_ sender: UIButton) {
        GIDSignIn.sharedInstance().disconnect()
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
            let controller = segue.destination as! MessagesTableViewController
            controller.selectedChatroom = selectedChatroom
        }
    }
}

extension ChatroomTableViewController: UITableViewDelegate, UITableViewDataSource {
    
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

extension ChatroomTableViewController: ChatroomDaoDelegate {
    
    func loaded(chatrooms: [Chatroom]) {
        chatRooms = chatrooms
        tableView.reloadData()
    }
}
