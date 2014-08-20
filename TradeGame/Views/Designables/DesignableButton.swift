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
        self.titleLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        self.titleLabel.textAlignment = NSTextAlignment.Center
        self.titleLabel.adjustsFontSizeToFitWidth = true;
        self.titleLabel.minimumScaleFactor = 0.5
        self.titleLabel.numberOfLines = 0
    }
}
