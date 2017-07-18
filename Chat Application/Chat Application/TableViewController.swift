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
        
        //updateUI()
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
        
        
        let cell = tableView.dequeueReusableCell( withIdentifier: "cell", for: indexPath) as! TableViewCell
        
        cell.setupCellWith(chatroom: chatRooms[indexPath.row])
        
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // performSegue(withIdentifier: "selectedSegue", sender: chatRooms[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "selectedSegue" {
            guard let object = sender as? Chatroom ,
                let destinationViewController = segue.destination as? SelectedViewController else { return }
            
            destinationViewController.chatroom = object
        }
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteChatroomIndexPath = indexPath as NSIndexPath
            let chatroomToDelete = chatRooms[indexPath.row]
            confirmDelete(chatroom : chatroomToDelete)
            
            
        }
    }
    func handleDeleteChatroom(alertAction: UIAlertAction!) -> Void {
        if let indexPath = deleteChatroomIndexPath {
            tableView.beginUpdates()
            
            chatroomDao.delete(chatroom: chatRooms[indexPath.row])
            
            chatRooms.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath as IndexPath], with: .automatic)
            
            deleteChatroomIndexPath = nil
            
            tableView.endUpdates()
        }
    }
    
    func cancelDeleteChatroom(alertAction: UIAlertAction!) {
        deleteChatroomIndexPath = nil
    }
    
    
    func confirmDelete(chatroom : Chatroom) {
        // TODO: Look up localization in iOS
        // TODO: Think about reusability here
        let alert = UIAlertController(title: NSLocalizedString("conve", comment: ""), message: NSLocalizedString("question1", comment: ""), preferredStyle: .actionSheet)
        
        let DeleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: handleDeleteChatroom)
        let CancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: cancelDeleteChatroom)
        
        alert.addAction(DeleteAction)
        alert.addAction(CancelAction)
        
        // Support display in iPad
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRect(x:self.view.bounds.size.width / 2.0, y:self.view.bounds.size.height / 2.0, width:1.0,height: 1.0)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
}

extension TableViewController: ChatroomDaoDelegate {
    
    func Loaded(chatrooms: [Chatroom]) {
        
        chatRooms = chatrooms
        tableView.reloadData()
    }
    
    
}
