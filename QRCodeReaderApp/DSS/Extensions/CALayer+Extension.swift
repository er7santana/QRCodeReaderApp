//
//  CALayer+Extension.swift
//  SantanderDesignSystem
//
//  Created by Wilson Kim on 29/06/20.
//  Copyright © 2020 Wilson Kim. All rights reserved.
//

import UIKit

extension CALayer {
    
    func removeShadow() {
        applySketchShadow(alpha: 0.0, x: 0, y: 0, blur: 0, spread: 0)
    }
    
    func applyFirstElevationShadow() {
        applySketchShadow(blur: 8)
    }
    
    func applySecondElevationShadow() {
        applySketchShadow(blur: 16)
    }
    
    public func applySketchShadow(
        color: UIColor = .black,
        alpha: Float = 0.12,
        x: CGFloat = 0,
        y: CGFloat = 4,
        blur: CGFloat = 8,
        spread: CGFloat = 0)
    {
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / 2.0
        if spread == 0 {
            shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
}
