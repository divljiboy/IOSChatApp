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
import Swinject
import SwinjectStoryboard

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
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

extension SwinjectStoryboard {
    
    @objc class func setup() {
        defaultContainer.register(UserRepositoryProtocol.self, name: String(describing: UserRepositoryProtocol.self)) { _ in
            return UserRemoteRepository()
        }
        defaultContainer.register(UserUseCaseProtocol.self, name: String(describing: UserUseCaseProtocol.self)) { resolver in
            UserUseCase(remoteRepository: resolver.resolve(UserRepositoryProtocol.self,
                                                           name: String(describing: UserRepositoryProtocol.self)) ?? UserRemoteRepository())
        }
        
        defaultContainer.register(MessageRepositoryProtocol.self, name: String(describing: MessageRepositoryProtocol.self)) { _ in
            return MessageRemoteRepository()
        }
        defaultContainer.register(MessageUseCaseProtocol.self, name: String(describing: MessageUseCaseProtocol.self)) { resolver in
            MessageUseCase(remoteRepository: resolver.resolve(MessageRepositoryProtocol.self,
                                                              name: String(describing: MessageRepositoryProtocol.self)) ?? MessageRemoteRepository())
        }
        
        defaultContainer.register(ConversationRepositoryProtocol.self, name: String(describing: ConversationRepositoryProtocol.self)) { resolver in
            return ConversationRemoteRepository(messageRepository: resolver.resolve(MessageRepositoryProtocol.self,
                                                                                    name: String(describing: MessageRepositoryProtocol.self)) ?? MessageRemoteRepository(), userRepository: resolver.resolve(UserRepositoryProtocol.self, name: String(describing: UserRepositoryProtocol.self)) ?? UserRemoteRepository())
        }
        defaultContainer.register(ConversationUseCaseProtocol.self, name: String(describing: ConversationUseCaseProtocol.self)) { resolver in
            ConversationUseCase(remoteRepository: resolver.resolve(ConversationRepositoryProtocol.self,
                                                                   name: String(describing: ConversationRepositoryProtocol.self)) ?? ConversationRemoteRepository(messageRepository: resolver.resolve(MessageRepositoryProtocol.self,
                                                                                                                                                                                        name: String(describing: MessageRepositoryProtocol.self)) ?? MessageRemoteRepository(), userRepository: resolver.resolve(UserRepositoryProtocol.self,
                                                                                                                                                                                                                                                                                                                                                               name: String(describing: UserRepositoryProtocol.self)) ?? UserRemoteRepository()))
        }
        
        defaultContainer.storyboardInitCompleted(InitialViewController.self) { resolver, controller in
            controller.userUseCase = resolver.resolve(UserUseCaseProtocol.self, name: String(describing: UserUseCaseProtocol.self))
        }
        
        defaultContainer.storyboardInitCompleted(ChatVC.self) { resolver, controller in
            controller.messageUseCase = resolver.resolve(MessageUseCaseProtocol.self, name: String(describing: MessageUseCaseProtocol.self))
        }
        defaultContainer.storyboardInitCompleted(WelcomeVC.self) { resolver, controller in
            controller.userUseCase = resolver.resolve(UserUseCaseProtocol.self, name: String(describing: UserUseCaseProtocol.self))
        }
        
        defaultContainer.storyboardInitCompleted(ConversationsVC.self) { resolver, controller in
            controller.userUseCase = resolver.resolve(UserUseCaseProtocol.self, name: String(describing: UserUseCaseProtocol.self))
            controller.conversationUseCase = resolver.resolve(ConversationUseCaseProtocol.self,
                                                              name: String(describing: ConversationUseCaseProtocol.self))
        }
        
        defaultContainer.storyboardInitCompleted(ContatctsViewController.self) { resolver, controller in
            controller.userUseCase = resolver.resolve(UserUseCaseProtocol.self, name: String(describing: UserUseCaseProtocol.self))
        }
    }
    
}
