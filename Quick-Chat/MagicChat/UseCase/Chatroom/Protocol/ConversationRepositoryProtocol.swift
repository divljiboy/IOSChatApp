//
//  ConversationRepositoryProtocol.swift
//  MagicChat
//
//  Created by Ivan Divljak on 6/27/18.
//  Copyright © 2018 Mexonis. All rights reserved.
//

import Foundation

protocol ConversationRepositoryProtocol {
    
    func showConversations(completion: @escaping ([Conversation]) -> Swift.Void)
    
}
