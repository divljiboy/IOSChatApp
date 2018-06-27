//
//  MessageUseCase.swift
//  MagicChat
//
//  Created by Ivan Divljak on 6/27/18.
//  Copyright © 2018 Mexonis. All rights reserved.
//

import Foundation

protocol MessageUseCaseProtocol {
    
    func downloadAllMessages(forUserID: String, completion: @escaping (Message) -> Swift.Void)
    func markMessagesRead(forUserID: String)
    func send(message: Message, toID: String, completion: @escaping (Bool) -> Swift.Void)
    func uploadMessage(withValues: [String: Any], toID: String, completion: @escaping (Bool) -> Swift.Void)
    func downloadImage(message: Message, indexpathRow: Int, completion: @escaping (Bool, Int, Message) -> Swift.Void)
    func downloadLastMessage(forLocation: String, completion: @escaping (Message) -> Swift.Void)
    
}

class MessageUseCase: MessageUseCaseProtocol {

    let remoteRepository: MessageRepositoryProtocol?
    
    init(remoteRepository: MessageRepositoryProtocol) {
        self.remoteRepository = remoteRepository
    }
    
    func downloadAllMessages(forUserID: String, completion: @escaping (Message) -> Void) {
        remoteRepository?.downloadAllMessages(forUserID: forUserID, completion: { message in
            completion(message)
        })
    }
    
    func markMessagesRead(forUserID: String) {
        remoteRepository?.markMessagesRead(forUserID: forUserID)
    }
    
    func send(message: Message, toID: String, completion: @escaping (Bool) -> Void) {
        remoteRepository?.send(message: message, toID: toID, completion: { isFinished in
            completion(isFinished)
        })
    }
    
    func uploadMessage(withValues: [String: Any], toID: String, completion: @escaping (Bool) -> Void) {
        remoteRepository?.uploadMessage(withValues: withValues, toID: toID, completion: { isFinished in
            completion(isFinished)
        })
    }
    
    func downloadImage(message: Message, indexpathRow: Int, completion: @escaping (Bool, Int, Message) -> Void) {
        remoteRepository?.downloadImage(message: message, indexpathRow: indexpathRow, completion: { isFinished, indexPath, message in
            completion(isFinished, indexPath, message)
        })
    }
    
    func downloadLastMessage(forLocation: String, completion: @escaping (Message) -> Void) {
        remoteRepository?.downloadLastMessage(forLocation: forLocation, completion: { message in
            completion(message)
        })
    }
    
}
