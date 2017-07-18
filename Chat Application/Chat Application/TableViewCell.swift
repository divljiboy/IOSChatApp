//
//  TableViewCell.swift
//  ChatApp
//
//  Created by Ivan Divljak on 7/11/17.
//  Copyright © 2017 Ivan Divljak. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var descChat: UILabel!
    
    @IBOutlet weak var nameChat: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setupCellWith(chatroom: Chatroom) {
        
        nameChat.text = chatroom.name
        descChat.text = chatroom.description
    }
    
}
