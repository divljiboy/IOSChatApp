//  MIT License

//  Copyright (c) 2017 Haik Aslanyan

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        if let userInformation = UserDefaults.standard.dictionary(forKey: "userInformation") {
            guard let email = userInformation["email"] as? String,
                let password = userInformation["password"] as? String else {
                    return false
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
        
        return true
    }
    
    func pushTo(viewController: ViewControllerType) {
        
        switch viewController {
        case .conversations:
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            self.window = UIWindow(frame: UIScreen.main.bounds)
            guard let viewController = storyboard.instantiateViewController(withIdentifier: "homeNavigation") as? UINavigationController else {
                return
            }
            
            self.window?.rootViewController = viewController
            self.window?.makeKeyAndVisible()
        case .welcome:
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            self.window = UIWindow(frame: UIScreen.main.bounds)
            guard let viewController = storyboard.instantiateViewController(withIdentifier: "loginNavigation") as? UINavigationController else {
                return
            }
            
            self.window?.rootViewController = viewController
            self.window?.makeKeyAndVisible()
        }
    }
}
