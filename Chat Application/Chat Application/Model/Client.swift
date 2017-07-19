//
//  User.swift
//  Chat Application
//
//  Created by Ivan Divljak on 7/17/17.
//  Copyright © 2017 Ivan Divljak. All rights reserved.
//

import Foundation
import Firebase
import ObjectMapper
import GoogleSignIn


class Client {
    
    
    var id : String?
    var name : String?
    var email : String?
    var url : String?
    
    
    required init?(map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        self.id    <- map["id"]
        self.name  <- map["name"]
        self.email <- map["email"]
        self.url   <- map["url"]
        
    }
    
    init() {}
    
    init(id:String,name: String,email: String, url: String){
        self.id = id
        self.name = name
        self.email = email
        self.url = url
    }
    func toJSON()-> NSDictionary{
        
        return ["id": self.id ?? "",
                "name": self.name ?? "",
                "email": self.email ??  "",
                "url" : self.url ?? "" ]
        
        
    }
    init(snapshot: [String:AnyObject]) {
        
        self.id = snapshot["id"] as? String
        self.name = snapshot["name"] as? String
        self.email = snapshot["email"] as? String
        self.url = snapshot["url"] as? String
        
        
        
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
    init( user : User) {
        self.id = user.uid
        self.name = user.displayName
        self.email = user.email
        self.url = user.photoURL?.absoluteString
    }
}
