//
//  HexagonalView.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 13/10/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

@IBDesignable
class HexagonalView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        // Initialization code
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
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

    func setup() {
        let maskLayer = CAShapeLayer()
        maskLayer.fillRule = kCAFillRuleEvenOdd
        maskLayer.frame = self.bounds

        let w = self.frame.size.width
        let h = self.frame.size.height
        let pad = w / 8 / 2

        UIGraphicsBeginImageContext(self.frame.size)
        let path = UIBezierPath()
        path.moveToPoint(CGPointMake(w / 2, 0))
        path.addLineToPoint(CGPointMake(w - pad, h / 4))
        path.addLineToPoint(CGPointMake(w - pad, h * 3 / 4))
        path.addLineToPoint(CGPointMake(w / 2, h))
        path.addLineToPoint(CGPointMake(pad, h * 3 / 4))
        path.addLineToPoint(CGPointMake(pad, h / 4))
        path.closePath()
        path.fill()
        maskLayer.path = path.CGPath
        UIGraphicsEndImageContext()
        self.layer.mask = maskLayer
    }
}
