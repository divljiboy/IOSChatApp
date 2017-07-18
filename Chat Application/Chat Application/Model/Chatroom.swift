//
//  Chatroom.swift
//  Chat Application
//
//  Created by Ivan Divljak on 7/17/17.
//  Copyright © 2017 Ivan Divljak. All rights reserved.
//

import Foundation
import Firebase

class Chatroom  {
    
    var name:String?
    var description: String?
    var id:String?
    var url:String?
    
    init(){
    }
    
    
    init(id:String,name:String,description:String){
        
        self.id=id
        self.name=name
        self.description=description
    }
    
    init(name:String,description:String) {
        
        self.name=name
        self.description=description
        
    }
    init(snapshot: DataSnapshot) {
        
        guard let snapshotValue = snapshot.value as? [String:AnyObject]else {
            print ("Snapshot value did not cast properly ")
            return
        }
        self.id = snapshotValue["id"] as? String
        self.name = snapshotValue["name"] as? String
        self.description = snapshotValue["description"] as? String
    }
}
