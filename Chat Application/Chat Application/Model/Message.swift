//
//  Messages.swift
//  Chat Application
//
//  Created by Ivan Divljak on 7/18/17.
//  Copyright © 2017 Ivan Divljak. All rights reserved.
//

import Foundation
import Firebase
import ObjectMapper

class Message {
    
    var name:String?
    var date : String?
    var id:String?
    var client: Client?
    
    init(){
    }
    
    
    init(id:String,name:String,date: String,client: Client){
        
        self.id = id
        self.name = name
        self.date = date
        self.client = client
    }
    
    init(name:String) {
        
        self.name = name
        
    }
    init(snapshot: DataSnapshot) {
        
        guard let snapshotValue = snapshot.value as? [String:AnyObject]else {
            print ("Snapshot value did not cast properly ")
            return
        }
        self.id = snapshotValue["id"] as? String
        self.name = snapshotValue["name"] as? String
        self.date = snapshotValue["date"] as? String
        
        guard let snapshotClient = snapshotValue["client"] as? [String:AnyObject] else {
            print ("Snapshot value did not cast properly ")
            return
        }
        self.client = Client(snapshot: snapshotClient)
        
        
        
    }
}
