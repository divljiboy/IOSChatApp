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
    
    let clientTag = "client_profiles"
    var refHandle : UInt!
    var clientList : [Client]=[]
    
    
    func get() {
        let databaseRef : DatabaseReference = Database.database().reference().child(clientTag)
        refHandle = databaseRef.observe(.value, with: { (snapshot) in
            if snapshot.exists() {
                self.clientList.removeAll()
                for item in snapshot.children {
                    guard let singleChatroom = item as? DataSnapshot else {
                        continue
                    }
                    let client = Client( snapshot: singleChatroom)
                    self.clientList.append(client)
                }
            }
        })
    }
    func delete(client : Client) {
        guard let clientId = client.id else {
            return
        }
        let databaseRef : DatabaseReference = Database.database().reference().child(clientTag).child(clientId)
        databaseRef.removeValue()
    }
    
    func write(client : Client){
        let databaseRef : DatabaseReference = Database.database().reference().child(clientTag)
        databaseRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let clientID = client.id,
                  let userID = Auth.auth().currentUser?.uid else {
                    return
            }
            if snapshot.hasChild(clientID) {
                print("Already in database")
                return
            } else {
                let dictionary : [String:Any] = ["id": userID,
                                                 "name":client.name ?? "",
                                                 "email": client.email ?? "",
                                                 "url": client.url ?? ""]
                databaseRef.child(userID).setValue(dictionary)
            }
        })
    }
}
