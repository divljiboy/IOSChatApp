//
//  ViewUtility.swift
//  MagicChat
//
//  Created by Ivan Divljak on 6/15/18.
//  Copyright © 2018 Mexonis. All rights reserved.
//

import Foundation
import UIKit

class AlertUtility {
    
    /**
     Presents alert with custom number of actions.
     
     - Parameter controller:  Alert parent controller.
     - Parameter choices:     List of choices of alert dialogue.
     - Parameter title:       Alert's title.
     - Parameter message:     Alert's message.
     - Parameter completion:  Callback function that sends which button was clicked.
     
     */
    static func showCustomDialog(_ controller: UIViewController,
                                 choices: [DialogWrapper],
                                 title: String? = nil,
                                 message: String? = nil, textAligment: NSTextAlignment? = nil) {
        let mutableStringTitle = NSMutableAttributedString(string: title ?? "",
                                                           attributes: [NSAttributedStringKey.font:
                                                            UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)])
        let mutableStringMessage = NSMutableAttributedString(string: message ?? "",
                                                             attributes: [:])
        let dialogue = UIAlertController(title: title, message: message, preferredStyle: .alert)
        dialogue.setValue(mutableStringTitle, forKey: "attributedTitle")
        dialogue.setValue(mutableStringMessage, forKey: "attributedMessage")
        for choice in choices {
            guard let title = choice.title,
                let uiAction = choice.uiAction else {
                    return
            }
            let action = UIAlertAction(title: title, style: uiAction, handler: choice.handler)
            if let image = choice.image {
                action.setValue(image, forKey: "image")
            }
            
            dialogue.addAction(action)
        }
        DispatchQueue.main.async {
            controller.present(dialogue, animated: true, completion: nil)
        }
    }
    
}

struct DialogWrapper {
    
    let title: String?
    let uiAction: UIAlertActionStyle?
    let image: UIImage?
    let handler: ((UIAlertAction) -> Void)?
    
    init(dialogWrapper: DialogWrapper? = nil, title: String? = nil, uiAction: UIAlertActionStyle? = nil, image: UIImage? = nil,
         handler: ((UIAlertAction) -> Void)? = nil) {
        self.title = title ?? dialogWrapper?.title
        self.uiAction = uiAction ?? dialogWrapper?.uiAction
        self.image = image ?? dialogWrapper?.image
        self.handler = handler ?? dialogWrapper?.handler
    }
}
