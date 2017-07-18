//
//  Messages.swift
//  Chat Application
//
//  Created by Ivan Divljak on 7/18/17.
//  Copyright © 2017 Ivan Divljak. All rights reserved.
//

import Foundation
import Firebase

class Message {
    
    var name:String?
    var date : Date?
    var id:String?
    var userID: String?
    
    init(){
    }
    
    
    init(id:String,name:String,date: Date,userID : String){
        
        self.id = id
        self.name = name
        self.date = date
        self.userID = userID
    }
    
    init(name:String,date: Date,userID : String) {
        
        self.name = name
        self.date = date
        self.userID = userID
        
    }
    init(snapshot: DataSnapshot) {
        
        guard let snapshotValue = snapshot.value as? [String:AnyObject]else {
            print ("Snapshot value did not cast properly ")
            return
        }
        self.id = snapshotValue["id"] as? String
        self.name = snapshotValue["name"] as? String
        self.date = snapshotValue["date"] as? Date
        self.userID = snapshotValue["userid"] as? String
    }
}
