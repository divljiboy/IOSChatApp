//
//  AccountViewController.swift
//  MagicChat
//
//  Created by Ivan Divljak on 6/22/18.
//  Copyright © 2018 Mexonis. All rights reserved.
//

import UIKit

protocol AccountDialogDelegate: NSObjectProtocol {
    
    func dialogDismissed()
    
    func logOut()
    
}

class AccountViewController: UIViewController {
    
    @IBOutlet weak var accountView: UIView!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: RoundedImageView!
    weak var delegate: AccountDialogDelegate?
    var user: User!
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissController))
        view.addGestureRecognizer(tap)
        userEmail.text = user.email
        userName.text = user.name
        userImage.image = user.profilePic
        accountView.layer.cornerRadius = 10
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func proceedLogOut(_ sender: Any) {
        delegate?.logOut()
        dismiss(animated: true, completion: nil)
    }
    
    /**
     Dismisses modal controller
     */
    @objc func dismissController() {
        delegate?.dialogDismissed()
        dismiss(animated: true, completion: nil)
    }
    
    /**
     Close dialog action clicke.
     */
    @IBAction func closeActionClicked(_ sender: Any) {
        dismissController()
    }

}
