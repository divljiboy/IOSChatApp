//
//  ChatroomDao.swift
//  ChatApp
//
//  Created by Ivan Divljak on 7/11/17.
//  Copyright © 2017 Ivan Divljak. All rights reserved.
//

import Foundation
import Firebase

protocol ChatroomDaoDelegate: class {
    func Loaded(chatrooms: [Chatroom])
}

class ChatroomDao{
    
    var chatroomList = [Chatroom]()
    private var refHandle: UInt!
    
    private var Chatroom_Tag:String = "Chatrooms"
    
    weak var delegate: ChatroomDaoDelegate?
    
    func get() {
        
        let databaseRef: DatabaseReference = Database.database().reference().child(Chatroom_Tag)
        
        refHandle = databaseRef.observe(.value, with: { (snapshot) in
            if snapshot.exists() {
                
                self.chatroomList.removeAll()
                
                for item in snapshot.children {
                    
                    guard let singleChatroom = item as? DataSnapshot else {
                        continue
                    }
                    
                    let chatroom = Chatroom( snapshot: singleChatroom)
                    self.chatroomList.append(chatroom)
                }
                
                self.delegate?.Loaded(chatrooms: self.chatroomList)
            }
            
        })
        
        
    }
    func delete(chatroom : Chatroom ){
        
        guard let chatroomId = chatroom.id else {
            return
        }
        
        let databaseRef : DatabaseReference = Database.database().reference().child(Chatroom_Tag)
        databaseRef.child(chatroomId).removeValue()
        
        databaseRef.observeSingleEvent(of: .value) { (datasnapshot, string) in
            
            self.chatroomList.removeAll()
            
            for item in datasnapshot.children {
                
                guard let singleChatroom = item as? DataSnapshot else {
                    continue
                }
                
                let chatroom = Chatroom( snapshot: singleChatroom)
                self.chatroomList.append(chatroom)
            }
            
            self.delegate?.Loaded(chatrooms: self.chatroomList)
        }
        
        
    }
    
    func write(chat : Chatroom){
        print ("upisujem")
        let databaseRef : DatabaseReference = Database.database().reference().child(Chatroom_Tag).childByAutoId()
        
        databaseRef.setValue(["id": databaseRef.key,"name":chat.name,
                              "description": chat.description])
        
    }
}
