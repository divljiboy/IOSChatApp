//
//  UINavigationBar.swift
//  MagicChat
//
//  Created by Ivan Divljak on 6/14/18.
//  Copyright © 2018 Mexonis. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationBar {
    
    /**
     Sets gradient based on parametes.
     
     - Parameters: colors: Colors that are used in gradient.
     - Parameters: locations: Locations where gradient is being applied.
     */
    func setGradientBackground(colors: [UIColor], locations: [NSNumber]) {
        let navFrame = frame
        let newframe = CGRect(origin: .zero, size: CGSize(width: navFrame.width,
                                                          height: (navFrame.height + UIApplication.shared.statusBarFrame.height) ))
        let gradientLayer = CAGradientLayer(frame: newframe, colors: colors, locations: locations,
                                            navigation: true, firstAngle: Constants.firstAngle,
                                            secondAngle: Constants.secondAngle)
        guard let image = gradientLayer.createGradientImage() else {
            return
        }
        barTintColor = UIColor(patternImage: image)
    }
}
