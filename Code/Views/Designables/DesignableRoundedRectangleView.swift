//
//  DesignableRoundedRectangleView.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/1/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

@IBDesignable
class DesignableRoundedRectangleView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    @IBInspectable var cornerRadius: CGFloat = 1{
        didSet{
            layer.cornerRadius = cornerRadius
        }
    }
    
    func setup(){
        self.backgroundColor = UIColor.blackColor()
    }
    
    override func prepareForInterfaceBuilder() {
        setup()
    }
}
