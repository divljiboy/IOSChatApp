//
//  MessageRepositoryProtocol.swift
//  MagicChat
//
//  Created by Ivan Divljak on 6/27/18.
//  Copyright © 2018 Mexonis. All rights reserved.
//

import Foundation

protocol MessageRepositoryProtocol {
    
    func downloadAllMessages(forUserID: String, completion: @escaping (Message) -> Swift.Void)
    func markMessagesRead(forUserID: String)
    func send(message: Message, toID: String, completion: @escaping (Bool) -> Swift.Void)
    func uploadMessage(withValues: [String: Any], toID: String, completion: @escaping (Bool) -> Swift.Void)
    func downloadImage(message: Message, indexpathRow: Int, completion: @escaping (Bool, Int, Message) -> Swift.Void)
    func downloadLastMessage(forLocation: String, completion: @escaping (Message) -> Swift.Void)
    
}
