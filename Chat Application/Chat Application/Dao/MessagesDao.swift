//
//  MessagesDao.swift
//  Chat Application
//
//  Created by Ivan Divljak on 7/18/17.
//  Copyright © 2017 Ivan Divljak. All rights reserved.
//

import Foundation
import Firebase

protocol MessageDaoDelegate: class {
    func loaded(messages: [Message])
}

class MessagesDao {
    
    var messagesList = [Message]()
    private var refHandle: UInt!
    
    private var messageTag:String = "Messages"
    
    weak var delegate: MessageDaoDelegate?
    
    func getMessages(chatRoom: Chatroom) {
        guard let chatroomId = chatRoom.id else {
            print("Didnt get coorect id")
            return
        }
        
        let databaseRef: DatabaseReference = Database.database().reference().child(messageTag).child(chatroomId)
        
        refHandle = databaseRef.observe(.value, with: { (snapshot) in
            if snapshot.exists() {
                
                self.messagesList.removeAll()
                
                for item in snapshot.children {
                    
                    guard let singleMessage = item as? DataSnapshot else {
                        continue
                    }
                    
                    let message = Message( snapshot: singleMessage)
                    
                    self.messagesList.append(message)
                }
                
                self.delegate?.loaded(messages : self.messagesList)
            }
            
        })
    }
    
    
    func write(message : Message, chatroom: Chatroom){
        
        guard let chatroomId = chatroom.id else {
            print("Didnt get correct id")
            return
        }
        
        let date = String(describing: Date())
        
        let databaseRef : DatabaseReference = Database.database().reference().child(messageTag).child(chatroomId).childByAutoId()
        
        guard let user = Auth.auth().currentUser else {
          return
        }
        let client = Client(user:user)
        
        let dictionary : [String : Any] = ["id": databaseRef.key,"name": message.name ?? "",
                                           "date": date,"client": client.toJSON()]
        
        databaseRef.setValue(dictionary)
        
    }
}
