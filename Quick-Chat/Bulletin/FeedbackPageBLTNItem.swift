//
//  FeedbackPageBLTNItem.swift
//  QuickChat
//
//  Created by Ivan Divljak on 6/22/18.
//  Copyright © 2018 Mexonis. All rights reserved.
//

import Foundation
import BLTNBoard

/**
 * A subclass of page bulletin item that plays an haptic feedback when the buttons are pressed.
 *
 * This class demonstrates how to override `PageBLTNItem` to customize button tap handling.
 */

class FeedbackPageBLTNItem: BLTNPageItem {
    
    private let feedbackGenerator = SelectionFeedbackGenerator()
    
    override func actionButtonTapped(sender: UIButton) {
        
        // Play an haptic feedback
        
        feedbackGenerator.prepare()
        feedbackGenerator.selectionChanged()
        
        // Call super
        
        super.actionButtonTapped(sender: sender)
        
    }
    
    override func alternativeButtonTapped(sender: UIButton) {
        
        // Play an haptic feedback
        
        feedbackGenerator.prepare()
        feedbackGenerator.selectionChanged()
        
        // Call super
        
        super.alternativeButtonTapped(sender: sender)
        
    }
    
}
