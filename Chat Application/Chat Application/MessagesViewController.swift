//
//  MessagesViewController.swift
//  Chat Application
//
//  Created by Ivan Divljak on 7/18/17.
//  Copyright © 2017 Ivan Divljak. All rights reserved.
//

import UIKit

class MessagesViewController: UIViewController {
    
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
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    

}


extension MessagesViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return messagesList.count
        
    }
    
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        // TODO: implement logic
        let cell = tableView.dequeueReusableCell( withIdentifier: "cell", for: indexPath) as! TableViewCell
        
       // cell.setupCellWith(message : messagesList[indexPath.row])
        
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
   /* func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
    }*/
    
}


extension MessagesViewController: MessageDaoDelegate {
    
    func Loaded(messages: [Message]) {
        
        messagesList = messages
        tableView.reloadData()
    }
    
    
}
