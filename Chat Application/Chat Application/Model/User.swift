//
//  User.swift
//  Chat Application
//
//  Created by Ivan Divljak on 7/17/17.
//  Copyright © 2017 Ivan Divljak. All rights reserved.
//

import Foundation
import Firebase

class User {
    
    
    var id : String?
    var name : String?
    var email : String?
    var url : String?
    
    
    init() {}
    
    init(id:String,name: String,email: String, url: String){
        self.id = id
        self.name = name
        self.email = email
        self.url = url
    }
    
    init(snapshot: DataSnapshot) {
        
        guard let snapshotValue = snapshot.value as? [String:AnyObject]else {
            return
        }
        
        self.id = snapshotValue["id"] as? String
        self.name = snapshotValue["name"] as? String
        self.email = snapshotValue["email"] as? String
        self.url = snapshotValue["url"] as? String
        
    }
}
