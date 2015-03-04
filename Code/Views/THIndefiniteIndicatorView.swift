//
//  THIndefiniteIndicatorView.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 9/9/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit
import JGProgressHUD

class THIndefiniteIndicatorView: JGProgressHUDIndicatorView {

    init(style: JGProgressHUDStyle) {
        var width: CGFloat = 50
        if UIScreen.mainScreen().bounds.width > 640 {
            width = 100
        }
        var indicatorView = THIndefiniteAnnularIndicatorView(frame: CGRectMake(0, 0, width, width))
        switch style {
        case .ExtraLight:
            indicatorView.strokeColor = UIColor.blackColor()
        case .Light:
            indicatorView.strokeColor = UIColor.darkGrayColor()
        case .Dark:
            indicatorView.strokeColor = UIColor.whiteColor()
        }
        super.init(contentView: indicatorView)
    }

    convenience override init() {
        self.init(style: .ExtraLight)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class THIndefiniteAnnularIndicatorView: UIView {

    private let THIndefiniteIndicatorViewRingRadius: CGFloat = 18.0
    private let THIndefiniteIndicatorViewRingNoTextRadius: CGFloat = 24.0
    private let THIndefiniteIndicatorViewRingThickness: CGFloat = 4.0
    private let THIndefiniteIndicatorViewForegroundColor = UIColor.blackColor()

    var strokeThickness: CGFloat {
        didSet {
            self.indefiniteAnimatedLayer.lineWidth = self.strokeThickness
        }
    }

    var radii: CGFloat {
        didSet {
            indefiniteAnimatedLayer.removeFromSuperlayer()
            indefiniteAnimatedLayer = nil
            self.layoutAnimatedLayer()
        }
    }
    var strokeColor: UIColor {
        didSet {
            self.indefiniteAnimatedLayer.strokeColor = self.strokeColor.CGColor
        }
    }

    private var _indefiniteAnimatedLayer: CAShapeLayer!

    private var indefiniteAnimatedLayer: CAShapeLayer! {
        get {
            if _indefiniteAnimatedLayer == nil {
                let arcCenter = CGPointMake(self.radii + self.strokeThickness / 2 + 5, self.radii + self.strokeThickness / 2 + 5)
                let rect = CGRectMake(0, 0, arcCenter.x * 2, arcCenter.y * 2)

                let smoothedPath = UIBezierPath(arcCenter: arcCenter, radius: self.radii, startAngle: CGFloat(M_PI) * 3 / 2, endAngle: CGFloat(M_PI) / 2 + CGFloat(M_PI) * 5, clockwise: true)
                _indefiniteAnimatedLayer = CAShapeLayer()
                _indefiniteAnimatedLayer.contentsScale = UIScreen.mainScreen().scale
                _indefiniteAnimatedLayer.frame = rect
                _indefiniteAnimatedLayer.fillColor = UIColor.clearColor().CGColor
                _indefiniteAnimatedLayer.strokeColor = self.strokeColor.CGColor
                _indefiniteAnimatedLayer.lineWidth = self.strokeThickness
                _indefiniteAnimatedLayer.lineCap = kCALineCapRound
                _indefiniteAnimatedLayer.lineJoin = kCALineJoinBevel
                _indefiniteAnimatedLayer.path = smoothedPath.CGPath

                var maskLayer = CALayer()
                maskLayer.contents = UIImage(named: "IndefiniteViewAngleMask")!.CGImage
                maskLayer.frame = layer.bounds
                _indefiniteAnimatedLayer.mask = maskLayer

                let animationDuration: NSTimeInterval = 1
                let linearCurve = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
                var animation = CABasicAnimation(keyPath: "transform.rotation")
                animation.fromValue = 0
                animation.toValue = NSNumber(double: M_PI * 2)
                animation.duration = animationDuration
                animation.timingFunction = linearCurve
                animation.removedOnCompletion = false
                animation.repeatCount = Float.infinity
                animation.fillMode = kCAFillModeForwards
                animation.autoreverses = false
                _indefiniteAnimatedLayer.mask.addAnimation(animation, forKey: "rotate")

                var animationGroup = CAAnimationGroup()
                animationGroup.duration = animationDuration
                animationGroup.repeatCount = Float.infinity
                animationGroup.removedOnCompletion = false
                animationGroup.timingFunction = linearCurve

                var strokeStartAnimation = CABasicAnimation(keyPath: "strokeStart")
                strokeStartAnimation.fromValue = NSNumber(double: 0.015)
                strokeStartAnimation.toValue = NSNumber(double: 0.515)

                var strokeEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
                strokeEndAnimation.fromValue = NSNumber(double: 0.485)
                strokeEndAnimation.toValue = NSNumber(double: 0.985)

                animationGroup.animations = [strokeStartAnimation, strokeEndAnimation]
                _indefiniteAnimatedLayer.addAnimation(animationGroup, forKey: "progress")
            }
            return _indefiniteAnimatedLayer
        }

        set {
            _indefiniteAnimatedLayer = newValue
        }
    }

    override init(frame: CGRect) {
        strokeThickness = THIndefiniteIndicatorViewRingThickness
        radii = THIndefiniteIndicatorViewRingRadius
        strokeColor = THIndefiniteIndicatorViewForegroundColor
        super.init(frame: frame)
    }


    required init(coder aDecoder: NSCoder) {
        strokeThickness = THIndefiniteIndicatorViewRingThickness
        radii = THIndefiniteIndicatorViewRingRadius
        strokeColor = THIndefiniteIndicatorViewForegroundColor
        super.init(coder: aDecoder)
    }

    private func layoutAnimatedLayer() {
        var layer = self.indefiniteAnimatedLayer
        self.layer.addSublayer(layer)
        layer.position = CGPointMake(self.bounds.size.width - layer.bounds.size.width / 2, self.bounds.size.height - layer.bounds.size.height / 2)
    }

    override func willMoveToSuperview(newSuperview: UIView?) {
        if newSuperview != nil {
            self.layoutAnimatedLayer()
        } else {
            indefiniteAnimatedLayer.removeFromSuperlayer()
            indefiniteAnimatedLayer = nil
        }
    }

    override func sizeThatFits(size: CGSize) -> CGSize {
        return CGSizeMake((self.radii + self.strokeThickness / 2 + 5) * 2, (self.radii + self.strokeThickness / 2 + 5) * 2)
    }

    override var frame: CGRect {
        get {
            return super.frame
        }

        set {
            super.frame = newValue
            if self.superview != nil {
                self.layoutAnimatedLayer()
            }
        }

    }

}