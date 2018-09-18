//
//  UserUseCase.swift
//  MagicChat
//
//  Created by Ivan Divljak on 6/27/18.
//  Copyright © 2018 Mexonis. All rights reserved.
//

import Foundation
import UIKit

protocol UserUseCaseProtocol {
    
    func registerUser(withName: String, email: String, password: String, profilePic: UIImage, completion: @escaping (Bool) -> Swift.Void)
    func loginUser(withEmail: String, password: String, completion: @escaping (Bool) -> Swift.Void)
    func logOutUser(completion: @escaping (Bool) -> Swift.Void)
    func info(forUserID: String, completion: @escaping (User) -> Swift.Void)
    func downloadAllUsers(exceptID: String, completion: @escaping (User) -> Swift.Void)
    func checkUserVerification(completion: @escaping (Bool) -> Swift.Void)
    
}

class UserUseCase: UserUseCaseProtocol {
    
    let remoteRepository: UserRepositoryProtocol?
    
    init(remoteRepository: UserRepositoryProtocol) {
        self.remoteRepository = remoteRepository
    }
    
    func registerUser(withName: String, email: String, password: String, profilePic: UIImage, completion: @escaping (Bool) -> Void) {
        remoteRepository?.registerUser(withName: withName, email: email, password: password, profilePic: profilePic, completion: { isFinished in
            completion(isFinished)
        })
    }
    
    func loginUser(withEmail: String, password: String, completion: @escaping (Bool) -> Void) {
        remoteRepository?.loginUser(email: withEmail, password: password, completion: { isFinished in
            completion(isFinished)
        })
    }
    
    func logOutUser(completion: @escaping (Bool) -> Void) {
        remoteRepository?.logOutUser(completion: { isFinished in
            completion(isFinished)
        })
    }
    
    func info(forUserID: String, completion: @escaping (User) -> Void) {
        remoteRepository?.info(forUserID: forUserID, completion: { user in
            completion(user)
        })
    }
    
    func downloadAllUsers(exceptID: String, completion: @escaping (User) -> Void) {
        remoteRepository?.downloadAllUsers(exceptID: exceptID, completion: { user in
            completion(user)
        })
    }
    
    func checkUserVerification(completion: @escaping (Bool) -> Void) {
        remoteRepository?.checkUserVerification(completion: { isFinished in
            completion(isFinished)
        })
    }
    
}
