//
//  UserDao.swift
//  ChatApp
//
//  Created by Ivan Divljak on 7/12/17.
//  Copyright © 2017 Ivan Divljak. All rights reserved.
//

import Foundation
import Firebase

class UserDao{
    
    var userTag : String="user_profiles"
    var refHandle : UInt!
    var userList : [User]=[]
    
    
    func get() {
        
        
        let databaseRef : DatabaseReference = Database.database().reference().child(userTag)
        
        refHandle = databaseRef.observe(.value, with: { (snapshot) in
            
            if snapshot.exists() {
                
                self.userList.removeAll()
                
                for item in snapshot.children {
                    
                    guard let singleChatroom = item as? DataSnapshot else {
                        continue
                    }
                    let user = User( snapshot: singleChatroom)
                    self.userList.append(user)
                }
            }
        })
        
        
    }
    func delete(user : User){
        
        guard let userId = user.id else {
            return
        }
        
        let databaseRef : DatabaseReference = Database.database().reference().child(userTag).child(userId)
        databaseRef.removeValue()
        
    }
    
    func write(user : User){
        
        let databaseRef : DatabaseReference = Database.database().reference().child(userTag)
        
        
        databaseRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let userID = user.id else {
                return
            }
            
            if snapshot.hasChild(userID){
                print("Already in database")
                return
                
            }else{
                
                databaseRef.child((Auth.auth().currentUser?.uid)!).setValue(["id": Auth.auth().currentUser?.uid,"name":user.name,
                                                                             "email": user.email, "url": user.url])
            }
        })
        
    }
    
}
