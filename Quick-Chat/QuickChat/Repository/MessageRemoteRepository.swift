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
                            completion(Message.init(type: type, content: content, owner: fromID == currentUserID ? .receiver: .sender,
                                                    timestamp: timestamp, isRead: true))
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
    
    class func downloadImage(message: Message, indexpathRow: Int, completion: @escaping (Bool, Int, Message) -> Swift.Void) {
        if message.type == .photo {
            guard let imageLink = message.content as? String,
                let imageURL = URL.init(string: imageLink) else {
                    return
            }
            
            URLSession.shared.dataTask(with: imageURL, completionHandler: { data, _, error in
                if error == nil {
                    guard let data = data else {
                        return
                    }
                    message.image = UIImage.init(data: data)
                    completion(true, indexpathRow, message)
                }
            }).resume()
        }
    }
    
    class func downloadLastMessage(forLocation: String, completion: @escaping (Message) -> Swift.Void) {
        if let currentUserID = Auth.auth().currentUser?.uid {
            Database.database().reference().child("conversations").child(forLocation).observe(.value, with: { snapshot in
                if snapshot.exists() {
                    for snap in snapshot.children {
                        guard let tempSnap = snap as? DataSnapshot,
                            let receivedMessage = (tempSnap).value as? [String: Any],
                            let content = receivedMessage["content"],
                            let timeStamp = receivedMessage["timestamp"] as? Int,
                            let messageType = receivedMessage["type"] as? String,
                            let fromID = receivedMessage["fromID"] as? String,
                            let isRead = receivedMessage["isRead"] as? Bool else {
                                return
                        }
                        var type = MessageType.text
                        switch messageType {
                        case "text":
                            type = .text
                        case "photo":
                            type = .photo
                        case "location":
                            type = .location
                        default: break
                        }
                        completion(Message(type: type, content: content, owner: currentUserID == fromID ? .receiver: .sender,
                                           timestamp: timeStamp, isRead: isRead))
                    }
                }
            })
        }
    }
    
}
