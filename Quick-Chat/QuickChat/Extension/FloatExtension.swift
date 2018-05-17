//
//  FloatExtension.swift
//  Chat Application
//
//  Created by Ivan Divljak on 5/16/18.
//  Copyright © 2018 Ivan Divljak. All rights reserved.
//

import Foundation

extension FloatingPoint {
    func toRadians() -> Self {
        return self * .pi / 180
    }
    
    func toDegrees() -> Self {
        return self * 180 / .pi
    }
}
