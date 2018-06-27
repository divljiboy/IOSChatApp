//
//  ConversationUseCase.swift
//  MagicChat
//
//  Created by Ivan Divljak on 6/27/18.
//  Copyright © 2018 Mexonis. All rights reserved.
//

import Foundation

protocol ConversationUseCaseProtocol {
    
    func showConversations(completion: @escaping ([Conversation]) -> Swift.Void)
    
}

class ConversationUseCase: ConversationUseCaseProtocol {
    
    let remoteRepository: ConversationRepositoryProtocol?
    
    init(remoteRepository: ConversationRepositoryProtocol) {
        self.remoteRepository = remoteRepository
    }
    
    func showConversations(completion: @escaping ([Conversation]) -> Void) {
        remoteRepository?.showConversations(completion: { conversations in
            completion(conversations)
        })
    }
    
}
