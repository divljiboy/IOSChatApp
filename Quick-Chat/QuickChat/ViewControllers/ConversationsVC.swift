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
import AudioToolbox

class ConversationsVC: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var verifyLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    let showUserInfoSegue = "showUserInfo"
    let showContactsSegue = "showContacts"
    lazy var leftButton: UIBarButtonItem = {
        let image = UIImage.init(named: "default profile")?.withRenderingMode(.alwaysOriginal)
        let button = UIBarButtonItem.init(image: image, style: .plain, target: self, action: #selector(ConversationsVC.showProfile))
        return button
    }()
    var items = [Conversation]()
    var selectedUser: User?
    var user: User?
    var customView: UIView = UIView()
    
    let showSelectedSegue = "showSelected"
    
    func customization() {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        //NavigationBar customization
        guard let navigationTitleFont = UIFont(name: "AvenirNext-Regular", size: 18) else {
            return
        }
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: navigationTitleFont,
                                                                        NSAttributedStringKey.foregroundColor: UIColor.white]
        NotificationCenter.default.addObserver(self, selector: #selector(self.showEmailAlert),
                                               name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
        //right bar button
        guard let icon = UIImage.init(named: "compose")?.withRenderingMode(.alwaysOriginal) else {
            return
        }
        let rightButton = UIBarButtonItem.init(image: icon, style: .plain, target: self, action: #selector(ConversationsVC.showContacts))
        self.navigationItem.rightBarButtonItem = rightButton
        //left bar button image fetching
        self.navigationItem.leftBarButtonItem = self.leftButton
        self.tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        self.tableView.register(UINib(nibName: String(describing: ConversationsTableViewCell.self), bundle: nil),
                                forCellReuseIdentifier: String(describing: ConversationsTableViewCell.self))
        if let id = Auth.auth().currentUser?.uid {
            UserRemoteRepository.info(forUserID: id, completion: { [weak weakSelf = self] user in
                weakSelf?.user = user
                let contentSize = CGSize.init(width: 30, height: 30)
                UIGraphicsBeginImageContextWithOptions(contentSize, false, 0.0)
                _ = UIBezierPath.init(roundedRect: CGRect.init(origin: CGPoint.zero, size: contentSize), cornerRadius: 14).addClip()
                user.profilePic.draw(in: CGRect(origin: CGPoint.zero, size: contentSize))
                let path = UIBezierPath.init(roundedRect: CGRect.init(origin: CGPoint.zero, size: contentSize), cornerRadius: 14)
                path.lineWidth = 2
                UIColor.white.setStroke()
                path.stroke()
                guard let graphix = UIGraphicsGetImageFromCurrentImageContext() else {
                    return
                }
                let finalImage: UIImage = graphix.withRenderingMode(.alwaysOriginal)
                UIGraphicsEndImageContext()
                DispatchQueue.main.async {
                    weakSelf?.leftButton.image = finalImage
                    weakSelf = nil
                }
            })
        }
    }
    
    //Downloads conversations
    func fetchData() {
        ConversationRemoteRepository.showConversations { conversations in
            self.items = conversations
            self.items.sort {
                $0.lastMessage.timestamp > $1.lastMessage.timestamp
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                for conversation in self.items where conversation.lastMessage.isRead == false {
                        self.playSound()
                        break
                }
            }
        }
    }
    
    //Shows profile extra view
    @objc func showProfile() {
        self.navigationController?.view.addSubview( self.customView)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.1, animations: {
                self.customView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                self.navigationController?.view.bringSubview(toFront: self.customView)
            })
        }
        self.performSegue(withIdentifier: showUserInfoSegue, sender: nil)
    }
    
    //Shows contacts extra view
    @objc func showContacts() {
        self.navigationController?.view.addSubview( self.customView)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.1, animations: {
                self.customView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
                self.navigationController?.view.bringSubview(toFront: self.customView)
            })
        }
        self.performSegue(withIdentifier: showContactsSegue, sender: nil)
    }
    
    //Show EmailVerification on the bottom
    @objc func showEmailAlert() {
        UserRemoteRepository.checkUserVerification {[weak weakSelf = self] status in
            weakSelf?.verifyLabel.isHidden = status
            weakSelf = nil
        }
    }
    
    func playSound() {
        var soundURL: NSURL
        var soundID: SystemSoundID = 0
        guard let filePath = Bundle.main.path(forResource: "newMessage", ofType: "wav") else {
            return
        }
        soundURL = NSURL(fileURLWithPath: filePath)
        AudioServicesCreateSystemSoundID(soundURL, &soundID)
        AudioServicesPlaySystemSound(soundID)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSelectedSegue {
            guard let viewController = segue.destination as? ChatVC,
                  let user = sender as? User else {
                return
            }
            viewController.currentUser = user
        } else if segue.identifier == showUserInfoSegue {
            guard let controller = segue.destination as? AccountViewController else {
                return
            }
            controller.delegate = self
            controller.user = user
        } else if segue.identifier == showContactsSegue {
            guard let controller = segue.destination as? ContatctsViewController else {
                return
            }
            controller.delegate = self
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.items.isEmpty {
            return 1
        } else {
            return self.items.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.items.isEmpty {
            guard let height = self.navigationController?.navigationBar.bounds.height else {
                return 80
            }
            return self.view.bounds.height - height
        } else {
            return 80
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.items.count {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "Empty Cell") else {
                return UITableViewCell(style: .default, reuseIdentifier: "Cell")
            }
            return cell
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ConversationsTableViewCell.self),
                                                           for: indexPath) as? ConversationsTableViewCell else {
                return UITableViewCell(style: .default, reuseIdentifier: "Cell")
            }
            cell.clearCellData()
            cell.profilePic.image = self.items[indexPath.row].user.profilePic
            cell.nameLabel.text = self.items[indexPath.row].user.name
            switch self.items[indexPath.row].lastMessage.type {
            case .text:
                guard let message = self.items[indexPath.row].lastMessage.content as? String else {
                    return UITableViewCell(style: .default, reuseIdentifier: "Cell")
                }
                cell.messageLabel.text = message
            case .location:
                cell.messageLabel.text = "Location"
            default:
                cell.messageLabel.text = "Media"
            }
            let messageDate = Date.init(timeIntervalSince1970: TimeInterval(self.items[indexPath.row].lastMessage.timestamp))
            let dataformatter = DateFormatter.init()
            dataformatter.timeStyle = .short
            let date = dataformatter.string(from: messageDate)
            cell.timeLabel.text = date
            if self.items[indexPath.row].lastMessage.owner == .sender && self.items[indexPath.row].lastMessage.isRead == false {
                cell.nameLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 17.0)
                cell.messageLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 14.0)
                cell.timeLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 13.0)
                cell.profilePic.layer.borderColor = UIColor.green.cgColor
                cell.messageLabel.textColor = GlobalVariables.red
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !self.items.isEmpty {
            self.performSegue(withIdentifier: showSelectedSegue, sender: self.items[indexPath.row].user)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customization()
        self.fetchData()
        self.customView.frame = self.view.frame
        self.customView.backgroundColor = .clear
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.showEmailAlert()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectionIndexPath, animated: animated)
        }
    }
    //Downloads current user credentials
    func fetchUserInfo() {
        if let id = Auth.auth().currentUser?.uid {
            UserRemoteRepository.info(forUserID: id, completion: {[weak weakSelf = self] user in
                DispatchQueue.main.async {
                    weakSelf?.user = user
                    weakSelf = nil
                }
            })
        }
    }
}

extension ConversationsVC: AccountDialogDelegate {

    func dialogDismissed() {
        DispatchQueue.main.async {
            self.customView.removeFromSuperview()
        }
    }

    func logOut() {
        DispatchQueue.main.async {
            self.customView.removeFromSuperview()
            UserRemoteRepository.logOutUser { status in
                if status == true {
                    self.appDelegate.pushTo(viewController: .welcome)
                }
            }
        }
    }

}

extension ConversationsVC: ContatsDialogDelegate {
    func selected(user: User) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: self.showSelectedSegue, sender: user)
            self.customView.removeFromSuperview()
        }
    }
    
    func contactsDialogDismissed() {
        DispatchQueue.main.async {
            self.customView.removeFromSuperview()
        }
    }
}
