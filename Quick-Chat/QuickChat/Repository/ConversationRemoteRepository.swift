//
//  ConversationRemoteRepository.swift
//  QuickChat
//
//  Created by Ivan Divljak on 6/22/18.
//  Copyright © 2018 Mexonis. All rights reserved.
//

import Foundation
import Firebase

class ConversationRemoteRepository {
    
    class func showConversations(completion: @escaping ([Conversation]) -> Swift.Void) {
        if let currentUserID = Auth.auth().currentUser?.uid {
            var conversations = [Conversation]()
            Database.database().reference().child("users")
                .child(currentUserID).child("conversations").observe(.childAdded, with: { snapshot in
                    if snapshot.exists() {
                        let fromID = snapshot.key
                        
                        guard let values = snapshot.value as? [String: String],
                            let location = values["location"] else {
                                return
                        }
                        UserRemoteRepository.info(forUserID: fromID, completion: { user in
                            let emptyMessage = Message.init(type: .text, content: "loading", owner: .sender, timestamp: 0, isRead: true)
                            let conversation = Conversation.init(user: user, lastMessage: emptyMessage)
                            conversations.append(conversation)
                            MessageRemoteRepository.downloadLastMessage(forLocation: location, completion: { message in
                                conversation.lastMessage = message
                                completion(conversations)
                            })
                        })
                    }
                })
        }
    }
    
}
