//
//  BaseViewControllerV.swift
//  MagicChat
//
//  Created by Ivan Divljak on 5/17/18.
//  Copyright © 2018 Mexonis. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    let colors: [UIColor] = [UIColor.mtsNavigationBarColor, UIColor.mtsSecondNavigationBarColor]
    let locations: [NSNumber] = [0.0, 1]
    weak var appDelegate: AppDelegate!
    
    let progressHUD = ProgressHUD(text: "Please wait")
    
    override func viewDidLoad() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        self.appDelegate = appDelegate
        
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 177 / 255, green: 13 / 255, blue: 40 / 255, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.view.addSubview(progressHUD)
        self.setVisibleNavigation()
        stopActivityIndicatorSpinner()
    }
    
    /**
     Show spinner.
     */
    func startActivityIndicatorSpinner() {
        DispatchQueue.main.async {
            self.progressHUD.show()
        }
    }
    
    /**
     Set visible navigation bar and it's style.
     
     - Parameter color:       Navigation bar color.
     - Parameter borderColor: Navigation bar border color.
     
     */
    func setVisibleNavigation() {
        navigationController?.navigationBar.setGradientBackground(colors: colors, locations: locations)
    }
    
    /**
     Hide spinner.
     */
    func stopActivityIndicatorSpinner() {
        DispatchQueue.main.async {
            self.progressHUD.hide()
        }
    }
    
}

extension UIColor {
    
    class var mtsNavigationBarColor: UIColor {
        return UIColor(red: 5 / 255, green: 117 / 255, blue: 230 / 255, alpha: 1)
    }
    
    class var mtsSecondNavigationBarColor: UIColor {
        return UIColor(red: 38 / 255, green: 208 / 255, blue: 206 / 255, alpha: 1)
    }
}
