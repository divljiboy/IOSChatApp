//
//  SelectedViewController.swift
//  ChatApp
//
//  Created by Ivan Divljak on 7/11/17.
//  Copyright © 2017 Ivan Divljak. All rights reserved.
//

import UIKit

class SelectedViewController: UIViewController {
    
    @IBOutlet weak var editName: UITextField!
    
    @IBOutlet weak var editDesc: UITextField!
    
    @IBOutlet weak var editId: UITextField!
    
    
    var chatroom : Chatroom!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chatroom != nil{
            editName.text = chatroom.name
            editDesc.text = chatroom.description
            editId.text = chatroom.id
        }
    }
    
    @IBAction func cancelButtonClicked(_ sender: UIBarButtonItem) {

        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func saveButtonClicked(_ sender: UIBarButtonItem) {
        
        guard let editNameField = editName.text ,
               let editDescriptionField=editDesc.text else {
                return
        }
        let chatRoom = Chatroom(name: editNameField, description: editDescriptionField)
        ChatroomDao().write(chat: chatRoom)
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
        
    }
    
    
}
