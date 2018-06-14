//
//  MessageRemoteRepository.swift
//  QuickChat
//
//  Created by Ivan Divljak on 5/17/18.
//  Copyright © 2018 Mexonis. All rights reserved.
//

import Foundation
import Firebase

class MessageRemoteRepository {
    
    class func downloadAllMessages(forUserID: String, completion: @escaping (Message) -> Swift.Void) {
        if let currentUserID = Auth.auth().currentUser?.uid {
            Database.database().reference().child("users").child(currentUserID)
                .child("conversations").child(forUserID).observe(.value, with: { snapshot in
                if snapshot.exists() {
                    guard let data = snapshot.value as? [String: String],
                          let location = data["location"] else {
                        return
                    }
                    
                    Database.database().reference().child("conversations").child(location).observe(.childAdded, with: { snap in
                        if snap.exists() {
                            guard let receivedMessage = snap.value as? [String: Any],
                                  let messageType = receivedMessage["type"] as? String else {
                                return
                            }
                            
                            var type = MessageType.text
                            switch messageType {
                            case "photo":
                                type = .photo
                            case "location":
                                type = .location
                            default: break
                            }
                            guard let content = receivedMessage["content"] as? String,
                                  let fromID = receivedMessage["fromID"] as? String,
                                  let timestamp = receivedMessage["timestamp"] as? Int else {
                                return
                            }
                            
                            if fromID == currentUserID {
                                let message = Message.init(type: type, content: content, owner: .receiver, timestamp: timestamp, isRead: true)
                                completion(message)
                            } else {
                                let message = Message.init(type: type, content: content, owner: .sender, timestamp: timestamp, isRead: true)
                                completion(message)
                            }
                        }
                    })
                }
            })
        }
    }
    
    class func markMessagesRead(forUserID: String) {
        if let currentUserID = Auth.auth().currentUser?.uid {
            Database.database().reference().child("users").child(currentUserID)
                .child("conversations").child(forUserID).observeSingleEvent(of: .value, with: { snapshot in
                if snapshot.exists() {
                    guard let data = snapshot.value as? [String: String],
                          let location = data["location"] else {
                        return
                    }
                    
                    Database.database().reference().child("conversations").child(location).observeSingleEvent(of: .value, with: { snap in
                        if snap.exists() {
                            for item in snap.children {
                                guard let tempItem = item as? DataSnapshot,
                                      let receivedMessage = (tempItem).value as? [String: Any],
                                      let fromID = receivedMessage["fromID"] as? String else {
                                    return
                                }
                                if fromID != currentUserID {
                                    Database.database().reference().child("conversations")
                                        .child(location).child((tempItem).key).child("isRead").setValue(true)
                                }
                            }
                        }
                    })
                }
            })
        }
    }
    
    class func send(message: Message, toID: String, completion: @escaping (Bool) -> Swift.Void) {
        if let currentUserID = Auth.auth().currentUser?.uid {
            switch message.type {
            case .location:
                let values = ["type": "location", "content": message.content, "fromID": currentUserID,
                              "toID": toID, "timestamp": message.timestamp, "isRead": false]
                MessageRemoteRepository.uploadMessage(withValues: values, toID: toID, completion: { status in
                    completion(status)
                })
            case .photo:
                guard let image = message.content as? UIImage,
                      let imageData = UIImageJPEGRepresentation(image, 0.5) else {
                    return
                }
                
                let child = UUID().uuidString
                Storage.storage().reference().child("messagePics").child(child).putData(imageData, metadata: nil, completion: { _, error in
                    if error == nil {
                        Storage.storage().reference().child("messagePics").child(child).downloadURL { url, _ in
                            guard let path = url else {
                                // Uh-oh, an error occurred!
                                return
                            }
                            let values = ["type": "photo", "content": path.absoluteString, "fromID": currentUserID,
                                          "toID": toID, "timestamp": message.timestamp, "isRead": false] as [String: Any]
                            MessageRemoteRepository.uploadMessage(withValues: values, toID: toID, completion: { status in
                                completion(status)
                            })
                        }
                        
                    }
                })
            case .text:
                let values = ["type": "text", "content": message.content, "fromID": currentUserID,
                              "toID": toID, "timestamp": message.timestamp, "isRead": false]
                MessageRemoteRepository.uploadMessage(withValues: values, toID: toID, completion: { status in
                    completion(status)
                })
            }
        }
    }
    
    class func uploadMessage(withValues: [String: Any], toID: String, completion: @escaping (Bool) -> Swift.Void) {
        if let currentUserID = Auth.auth().currentUser?.uid {
            Database.database().reference().child("users").child(currentUserID)
                .child("conversations").child(toID).observeSingleEvent(of: .value, with: { snapshot in
                if snapshot.exists() {
                    guard let data = snapshot.value as? [String: String],
                          let location = data["location"] else {
                        return
                    }
                    
                    Database.database().reference().child("conversations")
                        .child(location).childByAutoId().setValue(withValues, withCompletionBlock: { error, _ in
                        if error == nil {
                            completion(true)
                        } else {
                            completion(false)
                        }
                    })
                } else {
                    Database.database().reference().child("conversations")
                        .childByAutoId().childByAutoId().setValue(withValues, withCompletionBlock: { _, reference in
                        guard let parent = reference.parent else {
                            return
                        }
                        let data = ["location": parent.key]
                        Database.database().reference().child("users").child(currentUserID).child("conversations").child(toID).updateChildValues(data)
                        Database.database().reference().child("users").child(toID).child("conversations").child(currentUserID).updateChildValues(data)
                        completion(true)
                    })
                }
            })
        }
    }
    
}
