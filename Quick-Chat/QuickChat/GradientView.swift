//
//  GradientView.swift
//  QuickChat
//
//  Created by Ivan Divljak on 5/17/18.
//  Copyright © 2018 Mexonis. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class GradientView: UIView {
    
    @IBInspectable var startColor: UIColor = UIColor(red: 177 / 255, green: 13 / 255, blue: 40 / 255, alpha: 1) {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var midColor: UIColor = UIColor(red: 237 / 255, green: 26 / 255, blue: 59 / 255, alpha: 1) {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var endColor: UIColor = UIColor(red: 245 / 255, green: 130 / 255, blue: 32 / 255, alpha: 1) {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var lineBreak: NSLineBreakMode = .byClipping {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var firstLocation: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var secondLocation: CGFloat = 0.5 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var thirdLocation: CGFloat = 0.9 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var startPointX: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var startPointY: CGFloat = 1 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var endPointX: CGFloat = 1 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var endPointY: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override func layoutSubviews() {
        guard let gradientLayer = layer as? CAGradientLayer else {
            return
        }
        gradientLayer.colors = [startColor.cgColor, midColor.cgColor, endColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: startPointX, y: startPointY)
        gradientLayer.endPoint = CGPoint(x: endPointX, y: endPointY)
        gradientLayer.locations = [NSNumber(value: Float(firstLocation)) , NSNumber(value: Float(secondLocation)), NSNumber(value: Float(thirdLocation))]
        layer.shadowOpacity = 1
    }
}
