//
//  ImagePreviewViewController.swift
//  MagicChat
//
//  Created by Ivan Divljak on 5/18/18.
//  Copyright © 2018 Mexonis. All rights reserved.
//

import UIKit

class ImagePreviewViewController: UIViewController {
    
    @IBOutlet weak var previewImageView: UIImageView!
    var image: UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        previewImageView.image = image
    }
    
    @IBAction func closeView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
