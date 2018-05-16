//
//  OutgoingTableViewCell.swift
//  Chat Application
//
//  Created by Ivan Divljak on 7/18/17.
//  Copyright © 2017 Ivan Divljak. All rights reserved.
//

import UIKit

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
    
    func setupCellWithoutgoing(message: Message) {
        
        let url = URL(string: (message.client?.url)!)
        messageImageView.layer.cornerRadius = 15
        messageImageView.layer.masksToBounds = true
        messageTextView.text = message.name
        messageTextView.layer.cornerRadius = 15
        messageTextView.layer.masksToBounds = true
        messageTextView.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        
        
    }
    func setupCellWithincomming(message: Message) {
        
        let url = URL(string: (message.client?.url)!)
        messageImageView.layer.cornerRadius = 15
        messageImageView.layer.masksToBounds = true
        messageTextView.text = message.name
        messageTextView.layer.cornerRadius = 15
        messageTextView.layer.masksToBounds = true
        messageTextView.backgroundColor = UIColor.gray
        messageTextView.backgroundColor = UIColor(red: 139/255, green: 157/255, blue: 195/255, alpha: 1)
        
        
        
    }
    
    
    
    
    
}
