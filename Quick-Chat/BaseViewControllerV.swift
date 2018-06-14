//
//  BaseViewControllerV.swift
//  QuickChat
//
//  Created by Ivan Divljak on 5/17/18.
//  Copyright © 2018 Mexonis. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    let colors: [UIColor] = [UIColor.mtsNavigationBarColor, UIColor.mtsMediumNavigationBarColor, UIColor.mtsSecondNavigationBarColor]
    let locations: [NSNumber] = [0.0, 0.5, 0.9]
    
    let progressHUD = ProgressHUD(text: "Please wait")
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 177 / 255, green: 13 / 255, blue: 40 / 255, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.view.addSubview(progressHUD)
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
    
    class var mtsMediumNavigationBarColor: UIColor {
        return UIColor(red: 237 / 255, green: 26 / 255, blue: 59 / 255, alpha: 1)
    }
    
    class var mtsNavigationBarColor: UIColor {
        return UIColor(red: 177 / 255, green: 13 / 255, blue: 40 / 255, alpha: 1)
    }
    
    class var mtsSecondNavigationBarColor: UIColor {
        return UIColor(red: 245 / 255, green: 130 / 255, blue: 32 / 255, alpha: 1)
    }
}
