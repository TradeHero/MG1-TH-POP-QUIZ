//
//  DesignableRoundedRectangleView.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/1/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

@IBDesignable
public class DesignableRoundedRectangleView: UIView {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        setup()
    }
    
    @IBInspectable public var cornerRadius: CGFloat = 1{
    didSet{
        layer.cornerRadius = cornerRadius
    }
    }
    
    public func setup(){
        self.backgroundColor = UIColor.blackColor()
    }
    
    override public func prepareForInterfaceBuilder() {
        setup()
    }
}
