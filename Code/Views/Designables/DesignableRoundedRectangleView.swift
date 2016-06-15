//
//  DesignableRoundedRectangleView.swift
//  TH-PopQuiz
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
        super.init(coder: aDecoder)!
        setup()
    }

    @IBInspectable var cornerRadius: CGFloat = 1 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
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

    func setup() {
//        self.backgroundColor = UIColor.blackColor()
    }

    override func prepareForInterfaceBuilder() {
        setup()
    }
}
