//
//  ConversationsTableViewCell.swift
//  MagicChat
//
//  Created by Ivan Divljak on 6/14/18.
//  Copyright © 2018 Mexonis. All rights reserved.
//

import UIKit

class ConversationsTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePic: RoundedImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    func clearCellData() {
        self.nameLabel.font = UIFont(name: "AvenirNext-Regular", size: 17.0)
        self.messageLabel.font = UIFont(name: "AvenirNext-Regular", size: 14.0)
        self.timeLabel.font = UIFont(name: "AvenirNext-Regular", size: 13.0)
        self.profilePic.layer.borderColor = UIColor.mtsNavigationBarColor.cgColor
        self.messageLabel.textColor = UIColor.red
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.profilePic.layer.borderWidth = 2
        self.profilePic.layer.borderColor = UIColor.mtsNavigationBarColor.cgColor
    }
    
}
