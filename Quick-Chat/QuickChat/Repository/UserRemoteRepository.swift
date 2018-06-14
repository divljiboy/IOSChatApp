//
//  UserRemoteRepository.swift
//  QuickChat
//
//  Created by Ivan Divljak on 5/17/18.
//  Copyright © 2018 Mexonis. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage
import Firebase

class UserRemoteRepository {
    
    class func registerUser(withName: String, email: String, password: String, profilePic: UIImage, completion: @escaping (Bool) -> Swift.Void) {
        Auth.auth().createUser(withEmail: email, password: password, completion: { user, error in
            if error == nil {
                user?.user.sendEmailVerification(completion: nil)
                guard let userUid = user?.user.uid else {
                    return
                }
                let storageRef = Storage.storage().reference().child("usersProfilePics").child(userUid)
                guard let imageData = UIImageJPEGRepresentation(profilePic, 0.1) else {
                    return
                }
                storageRef.putData(imageData, metadata: nil, completion: { _, err in
                    if err == nil {
                        
                        storageRef.downloadURL { url, _ in
                            guard let path = url?.absoluteString,
                                  let userId = user?.user.uid else {
                                return
                            }
                            let values = ["name": withName, "email": email, "profilePicLink": path]
                            Database.database().reference().child("users")
                                .child(userId).child("credentials").updateChildValues(values, withCompletionBlock: { errr, _ in
                                    if errr == nil {
                                        let userInfo = ["email": email, "password": password]
                                        UserDefaults.standard.set(userInfo, forKey: "userInformation")
                                        completion(true)
                                    }
                                })
                        }
                    }
                })
            } else {
                print(error ?? "")
                completion(false)
            }
        })
    }
    
    class func loginUser(withEmail: String, password: String, completion: @escaping (Bool) -> Swift.Void) {
        Auth.auth().signIn(withEmail: withEmail, password: password, completion: { _, error in
            if error == nil {
                let userInfo = ["email": withEmail, "password": password]
                UserDefaults.standard.set(userInfo, forKey: "userInformation")
                completion(true)
            } else {
                completion(false)
            }
        })
    }
    
    class func logOutUser(completion: @escaping (Bool) -> Swift.Void) {
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.removeObject(forKey: "userInformation")
            completion(true)
        } catch _ {
            completion(false)
        }
    }
    
    class func info(forUserID: String, completion: @escaping (User) -> Swift.Void) {
        Database.database().reference().child("users").child(forUserID).child("credentials").observeSingleEvent(of: .value, with: { snapshot in
            if let data = snapshot.value as? [String: String] {
                guard let name = data["name"],
                      let email = data["email"],
                      let pictureLink = data["profilePicLink"],
                      let link = URL.init(string: pictureLink) else {
                        return
                }
                URLSession.shared.dataTask(with: link, completionHandler: { data, _, error in
                    if error == nil {
                        guard let data = data,
                              let profilePic = UIImage.init(data: data) else {
                                return
                        }
                       
                        let user = User.init(name: name, email: email, id: forUserID, profilePic: profilePic)
                        completion(user)
                    }
                }).resume()
            }
        })
    }
    
    class func downloadAllUsers(exceptID: String, completion: @escaping (User) -> Swift.Void) {
        Database.database().reference().child("users").observe(.childAdded, with: { snapshot in
            let id = snapshot.key
            guard let data = snapshot.value as? [String: Any],
                  let credentials = data["credentials"] as? [String: String] else {
                return
            }
           
            if id != exceptID {
                guard let name = credentials["name"],
                      let email = credentials["email"],
                      let profileLink = credentials["profilePicLink"],
                      let link = URL.init(string: profileLink ) else {
                        return
                }
                URLSession.shared.dataTask(with: link, completionHandler: { data, _, error in
                    if error == nil {
                        guard let data = data,
                              let profilePic = UIImage.init(data: data) else {
                                return
                        }
                        let user = User.init(name: name, email: email, id: id, profilePic: profilePic)
                        completion(user)
                    }
                }).resume()
            }
        })
    }
    
    class func checkUserVerification(completion: @escaping (Bool) -> Swift.Void) {
        Auth.auth().currentUser?.reload(completion: { _ in
            guard let status = (Auth.auth().currentUser?.isEmailVerified) else {
                return
            }
            completion(status)
        })
    }
    
}
