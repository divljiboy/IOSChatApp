//
//  UserRepositoryProtocol.swift
//  MagicChat
//
//  Created by Ivan Divljak on 6/27/18.
//  Copyright © 2018 Mexonis. All rights reserved.
//

import Foundation
import UIKit

protocol UserRepositoryProtocol {

    func registerUser(withName: String, email: String, password: String, profilePic: UIImage, completion: @escaping (Bool) -> Swift.Void)
    func loginUser(email: String, password: String, completion: @escaping (Bool) -> Swift.Void)
    func logOutUser(completion: @escaping (Bool) -> Swift.Void)
    func info(forUserID: String, completion: @escaping (User) -> Swift.Void)
    func downloadAllUsers(exceptID: String, completion: @escaping (User) -> Swift.Void)
    func checkUserVerification(completion: @escaping (Bool) -> Swift.Void)

}
