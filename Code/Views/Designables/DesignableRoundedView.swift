//
//  DesignableRoundedView.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 8/1/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

@IBDesignable
class DesignableRoundedView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        // Initialization code
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup() {
        self.layer.cornerRadius = self.frame.size.width * 0.5
        //        self.layer.cornerRadius = self.bounds.size.width * 0.5
    }

    override func prepareForInterfaceBuilder() {
        setup()
    }

    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth;
        }
    }

    @IBInspectable var borderColor: UIColor = UIColor.clearColor() {
        didSet {
            layer.borderColor = borderColor.CGColor
        }
    }
}
