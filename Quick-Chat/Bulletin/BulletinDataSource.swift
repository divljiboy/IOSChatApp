//
//  BulletinDataSource.swift
//  QuickChat
//
//  Created by Ivan Divljak on 6/22/18.
//  Copyright © 2018 Mexonis. All rights reserved.
//

import Foundation
import UIKit
import BLTNBoard

enum BulletinDataSource {
    
    // MARK: - Pages
    
    /**
     * Create the introduction page.
     *
     * This creates a `FeedbackPageBLTNItem` with: a title, an image, a description text and
     * and action button.
     *
     * The action button presents the next item (the textfield page).
     */
    
    static func makeUserView(title: String, image: UIImage, description: String) -> FeedbackPageBLTNItem {
        
        let page = FeedbackPageBLTNItem(title: title)
        page.image = image
        
        page.descriptionText = description
        page.actionButtonTitle = "Log Out"
        
        page.isDismissable = true
        
        page.actionHandler = { item in
            UserRemoteRepository.logOutUser { status in
                item.manager?.dismissBulletin(animated: true)
            }
        }
        
        
        return page
        
    }
}
