//
//  InitialViewController.swift
//  QuickChat
//
//  Created by Ivan Divljak on 6/25/18.
//  Copyright © 2018 Mexonis. All rights reserved.
//

import UIKit

class InitialViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if let userInformation = UserDefaults.standard.dictionary(forKey: "userInformation") {
            guard let email = userInformation["email"] as? String,
                let password = userInformation["password"] as? String else {
                    return
            }
            UserRemoteRepository.loginUser(withEmail: email, password: password, completion: { [weak weakSelf = self] status in
                DispatchQueue.main.async {
                    if status == true {
                        weakSelf?.pushTo(viewController: .conversations)
                    } else {
                        weakSelf?.pushTo(viewController: .welcome)
                    }
                    weakSelf = nil
                }
            })
        } else {
            self.pushTo(viewController: .welcome)
        }
    }
    
    func pushTo(viewController: ViewControllerType) {
        
        switch viewController {
        case .conversations:
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            self.appDelegate.window = UIWindow(frame: UIScreen.main.bounds)
            guard let viewController = storyboard.instantiateViewController(withIdentifier: "homeNavigation") as? UINavigationController else {
                return
            }
            
            self.appDelegate.window?.rootViewController = viewController
            self.appDelegate.window?.makeKeyAndVisible()
        case .welcome:
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            self.appDelegate.window = UIWindow(frame: UIScreen.main.bounds)
            guard let viewController = storyboard.instantiateViewController(withIdentifier: "loginNavigation") as? UINavigationController else {
                return
            }
            
            self.appDelegate.window?.rootViewController = viewController
            self.appDelegate.window?.makeKeyAndVisible()
        }
    }
}
