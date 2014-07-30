//
//  Extension.swift
//  TradeGame
//
//  Created by Ryne Cheow on 7/30/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit



extension UIControl {
    func disable() {
        enabled = false
    }
    
    func enable() {
        enabled = true
    }
}

extension Array
    {
    /** Randomizes the order of an array's elements. */
    mutating func shuffle()
    {
        for _ in 0..<self.count
        {
            sort { (_,_) in arc4random() < arc4random() }
        }
    }
}


extension UIColor {
    
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let r = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let b = CGFloat((hex & 0xFF)) / 255.0
        self.init(red:r, green:g, blue:b, alpha:alpha)
    }
    
    public func lightenColorByValue(value:Float) -> UIColor!{
        let totalComponents = CGColorGetNumberOfComponents(self.CGColor)
        var isGrayscale = totalComponents == 2 ? true : false
        
        var oldComponents = CGColorGetComponents(self.CGColor)
        var newComponents: [CGFloat] = Array(count: 4, repeatedValue: 0.0)
        
        if isGrayscale {
            newComponents[0] = oldComponents[0] - CGFloat(value) < 0.0 ? 0.0 : oldComponents[0] - CGFloat(value)
            newComponents[1] = oldComponents[0] - CGFloat(value) < 0.0 ? 0.0 : oldComponents[0] - CGFloat(value)
            newComponents[2] = oldComponents[0] - CGFloat(value) < 0.0 ? 0.0 : oldComponents[0] - CGFloat(value)
            newComponents[3] = oldComponents[1]
        } else {
            newComponents[0] = oldComponents[0] + CGFloat(value) > 1.0 ? 1.0 : oldComponents[0] + CGFloat(value);
            newComponents[1] = oldComponents[1] + CGFloat(value) > 1.0 ? 1.0 : oldComponents[1] + CGFloat(value);
            newComponents[2] = oldComponents[2] + CGFloat(value) > 1.0 ? 1.0 : oldComponents[2] + CGFloat(value);
            newComponents[3] = oldComponents[3];
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let newColor = CGColorCreate(colorSpace, newComponents)
        
        return UIColor(CGColor:newColor)
    }
    
    
}
extension UIView {
    func removeAllSubviewsExceptSubview(subview:UIView?){
        for view in self.subviews as [UIView]{
            if let sv = subview {
                if view !== sv {
                    view.removeFromSuperview()
                }
            }
        }
    }
}