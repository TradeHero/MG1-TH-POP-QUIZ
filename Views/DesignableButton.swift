//
//  DesignableButton.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/1/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

@IBDesignable
public class DesignableButton: UIButton {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        // Initialization code
    }
    
  required public init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    public override func prepareForInterfaceBuilder() {
        layer.cornerRadius = cornerRadius
    }
    
    
    @IBInspectable public var borderColor: UIColor = UIColor.clearColor() {
    didSet {
        layer.borderColor = borderColor.CGColor
    }
    }
    
    @IBInspectable public var borderWidth: CGFloat = 0 {
    didSet {
        layer.borderWidth = borderWidth
    }
    }
    
    @IBInspectable public var cornerRadius: CGFloat = 6 {
    didSet {
        layer.cornerRadius = cornerRadius
    }
    }
    
}
