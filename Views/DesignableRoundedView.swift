//
//  DesignableRoundedView.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/1/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

@IBDesignable
public class DesignableRoundedView: UIView {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        // Initialization code
    }

  required public init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public func setup(){
        self.layer.cornerRadius = self.frame.size.width * 0.5
//        self.layer.cornerRadius = self.bounds.size.width * 0.5
    }
    
    override public func prepareForInterfaceBuilder() {
        setup()
    }
    
    @IBInspectable public var borderWidth: CGFloat = 0 {
    didSet{
        layer.borderWidth = borderWidth;
    }
    }

    @IBInspectable public var borderColor: UIColor = UIColor.clearColor() {
    didSet{
        layer.borderColor = borderColor.CGColor
    }
    }
}
