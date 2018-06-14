//  MIT License

//  Copyright (c) 2017 Haik Aslanyan

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation
import UIKit
import Firebase

class Message {
    
    var owner: MessageOwner
    var type: MessageType
    var content: Any
    var timestamp: Int
    var isRead: Bool
    var image: UIImage?
    private var toID: String?
    private var fromID: String?
    
    func downloadImage(indexpathRow: Int, completion: @escaping (Bool, Int) -> Swift.Void) {
        if self.type == .photo {
            guard let imageLink = self.content as? String,
                  let imageURL = URL.init(string: imageLink) else {
                return
            }
            
            URLSession.shared.dataTask(with: imageURL, completionHandler: { data, _, error in
                if error == nil {
                    guard let data = data else {
                        return
                    }
                    self.image = UIImage.init(data: data)
                    completion(true, indexpathRow)
                }
            }).resume()
        }
    }
    
    func downloadLastMessage(forLocation: String, completion: @escaping () -> Swift.Void) {
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
                        
                        self.content = content
                        self.timestamp = timeStamp
                        self.isRead = isRead
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
                        self.type = type
                        if currentUserID == fromID {
                            self.owner = .receiver
                        } else {
                            self.owner = .sender
                        }
                        completion()
                    }
                }
            })
        }
    }
    
    init(type: MessageType, content: Any, owner: MessageOwner, timestamp: Int, isRead: Bool) {
        self.type = type
        self.content = content
        self.owner = owner
        self.timestamp = timestamp
        self.isRead = isRead
    }
}
