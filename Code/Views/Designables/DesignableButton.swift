//
//  DesignableButton.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/1/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

@IBDesignable
class DesignableButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Initialization code
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func prepareForInterfaceBuilder() {
        setup()
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
    
    @IBInspectable var cornerRadius: CGFloat = 6 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    func setup(){
        if let t = self.titleLabel {
            t.lineBreakMode = NSLineBreakMode.ByWordWrapping
            t.textAlignment = NSTextAlignment.Center
            t.adjustsFontSizeToFitWidth = true;
            t.minimumScaleFactor = 8/t.font.pointSize
            t.numberOfLines = 3
        }
    }
}
