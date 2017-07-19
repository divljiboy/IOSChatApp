//
//  OutgoingTableViewCell.swift
//  Chat Application
//
//  Created by Ivan Divljak on 7/18/17.
//  Copyright © 2017 Ivan Divljak. All rights reserved.
//

import UIKit
import Kingfisher

class MessagesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var messageImageView: UIImageView!
    
    @IBOutlet weak var messageTextView: UITextView!
    
    @IBOutlet weak var dateLabel: UILabel!
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
        
    }
    func setupCellWith(message: Message) {
        
        let url = URL(string: (message.client?.url)!)
        messageImageView.kf.setImage(with: url)
        messageTextView.text = message.name
        dateLabel.text = message.date
        
    }
    
    
    
    
    
}
