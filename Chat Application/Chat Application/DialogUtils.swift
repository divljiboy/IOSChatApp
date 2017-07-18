//
//  DialogUtils.swift
//  Chat Application
//
//  Created by Ivan Divljak on 7/18/17.
//  Copyright © 2017 Ivan Divljak. All rights reserved.
//

import Foundation
import UIKit

public class DialogUtils: NSObject {
    
    
    
    
    public static func showYesNoDialog(_ controller: UIViewController, choises: [(String, UIAlertActionStyle)], completion: @escaping (_ selected: String) -> ()) {
        
        
        let alert = UIAlertController(title: NSLocalizedString("conve", comment: ""), message: NSLocalizedString("question1", comment: ""), preferredStyle: .actionSheet)
        for choise in choises {
            let action = UIAlertAction(title: NSLocalizedString(choise.0, comment: ""), style: choise.1, handler: {
                (alert: UIAlertAction!) -> Void in
                completion(choise.0)
            })
            alert.addAction(action)
        }
        DispatchQueue.main.async {
            controller.present(alert, animated: true, completion: nil)
        }
    }
    
    
}
