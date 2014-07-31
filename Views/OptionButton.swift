//
//  OptionButton.swift
//  TradeGame
//
//  Created by Ryne Cheow on 7/30/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

@IBDesignable
public class OptionButton: UIButton {

    init(frame: CGRect) {
        super.init(frame: frame)
        // Initialization code
    }
    
    public var option:String? = nil {
    didSet{
        self.setTitle(option, forState: UIControlState.Normal)    }
    }
    
//    @IBInspectable var borderColor: UIColor = UIColor.clearColor() {
//    didSet {
//        layer.borderColor = borderColor.CGColor
//    }
//    }
//    
//    @IBInspectable var borderWidth: CGFloat = 0 {
//    didSet {
//        layer.borderWidth = borderWidth
//    }
//    }
    
    @IBInspectable var cornerRadius: CGFloat = 06 {
    didSet {
        layer.cornerRadius = cornerRadius
    }
    }
    
    public var is_answer: Bool = false
    
    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
}