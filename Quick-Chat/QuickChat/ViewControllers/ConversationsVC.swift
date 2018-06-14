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
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var alertBottomConstraint: NSLayoutConstraint!
    lazy var leftButton: UIBarButtonItem = {
        let image = UIImage.init(named: "default profile")?.withRenderingMode(.alwaysOriginal)
        let button = UIBarButtonItem.init(image: image, style: .plain, target: self, action: #selector(ConversationsVC.showProfile))
        return button
    }()
    var items = [Conversation]()
    var selectedUser: User?
    
    let showSelectedSegue = "showSelected"
    
    func customization() {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        //NavigationBar customization
        guard let navigationTitleFont = UIFont(name: "AvenirNext-Regular", size: 18) else {
            return
        }
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: navigationTitleFont,
                                                                        NSAttributedStringKey.foregroundColor: UIColor.white]
        // notification setup
        NotificationCenter.default.addObserver(self, selector: #selector(self.pushToUserMesssages(notification:)),
                                               name: NSNotification.Name(rawValue: "showUserMessages"), object: nil)
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
                let image = user.profilePic
                let contentSize = CGSize.init(width: 30, height: 30)
                UIGraphicsBeginImageContextWithOptions(contentSize, false, 0.0)
                _ = UIBezierPath.init(roundedRect: CGRect.init(origin: CGPoint.zero, size: contentSize), cornerRadius: 14).addClip()
                image.draw(in: CGRect(origin: CGPoint.zero, size: contentSize))
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
        Conversation.showConversations { conversations in
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
        let info = ["viewType": ShowExtraView.profile]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showExtraView"), object: nil, userInfo: info)
        self.inputView?.isHidden = true
    }
    
    //Shows contacts extra view
    @objc func showContacts() {
        let info = ["viewType": ShowExtraView.contacts]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showExtraView"), object: nil, userInfo: info)
    }
    
    //Show EmailVerification on the bottom
    @objc func showEmailAlert() {
        UserRemoteRepository.checkUserVerification {[weak weakSelf = self] status in
            status == true ? (weakSelf?.alertBottomConstraint.constant = -40) : (weakSelf?.alertBottomConstraint.constant = 0)
            UIView.animate(withDuration: 0.3) {
                weakSelf?.view.layoutIfNeeded()
                weakSelf = nil
            }
        }
    }
    
    //Shows Chat viewcontroller with given user
    @objc func pushToUserMesssages(notification: NSNotification) {
        if let user = notification.userInfo?["user"] as? User {
            self.selectedUser = user
            self.performSegue(withIdentifier: showSelectedSegue, sender: self)
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
            guard let viewController = segue.destination as? ChatVC else {
                return
            }
            viewController.currentUser = self.selectedUser
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
                cell.profilePic.layer.borderColor = GlobalVariables.blue.cgColor
                cell.messageLabel.textColor = GlobalVariables.purple
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !self.items.isEmpty {
            self.selectedUser = self.items[indexPath.row].user
            self.performSegue(withIdentifier: showSelectedSegue, sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customization()
        self.fetchData()
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
}
