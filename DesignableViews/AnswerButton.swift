//
//  AnswerButton.swift
//  TradeGame
//
//  Created by Ryne Cheow on 7/30/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit


public class AnswerButton: UIButton {

    
    init(frame: CGRect) {
        super.init(frame: frame)
        // Initialization code
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clearColor() {
    didSet {
        layer.borderColor = borderColor.CGColor
    }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
    didSet {
        layer.borderWidth = borderWidth
    }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
    didSet {
        layer.cornerRadius = cornerRadius
    }
    }
    
    @IBInspectable var bgColor: UIColor = UIColor.clearColor() {
    didSet {
        backgroundColor = bgColor
    }
    }

    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
}
