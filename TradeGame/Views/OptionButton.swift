//
//  OptionButton.swift
//  TradeGame
//
//  Created by Ryne Cheow on 7/30/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

func radians(deg:CGFloat) -> CGFloat {
    return (deg * CGFloat(M_PI))/180.0
}

@IBDesignable
class OptionButton: DesignableButton {
    
    private let defaultBackgroundColour = UIColor(hex: 0x8BDBFB)
    
    private let defaultFontColor = UIColor(hex: 0x0C4FAE)
    
    private var defaultSize: CGSize!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Initialization code
    }
    
    var option:String? = nil {
    didSet{
        self.setTitle(option, forState: UIControlState.Normal)    }
    }
    
    var is_answer: Bool = false
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var wobbling: Bool = false

    var isShrinked: Bool = false
    
    var tiltedLeft: Bool = false
    
    var tiltedRight: Bool = false
    
    var tickLogoView = UIImageView(image: UIImage(named: "QuizTickIcon"))
    
    var crossLogoView = UIImageView(image: UIImage(named: "QuizCrossIcon"))
    
    private var tilted: Bool {
        return tiltedLeft || tiltedRight
    }
    
    func startWobble(){
        if !self.wobbling {
            self.wobbling = true
            self.transform = CGAffineTransformRotate(CGAffineTransformIdentity,radians(-3))
            
            UIView.animateWithDuration(0.1, delay: 0, options: .AllowUserInteraction | .Repeat | .Autoreverse, animations: {() -> Void in
                self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, radians(3))
                }, completion: nil)
        }
    }
    
    func stopWobble() {
        if self.wobbling {
            self.wobbling = false
            UIView.animateWithDuration(0.1, delay: 0, options: .AllowUserInteraction | .BeginFromCurrentState | .CurveLinear, animations: {() -> Void in
                self.transform = CGAffineTransformIdentity
                }, completion: nil)
        }
    }
    
    func shrink() {
        if !isShrinked {
            isShrinked = true
            var frame = self.frame
            self.defaultSize = self.frame.size
            frame.size.width = frame.size.width * 0.8
            frame.size.height = frame.size.height * 0.8
            self.frame = frame
        }
    }
    
    func unshrink() {
        if isShrinked{
            isShrinked = false
            if defaultSize == nil {
                let scale:CGFloat = 1.0/0.8
                var frame = self.frame
                frame.size.width = frame.size.width * scale
                frame.size.height = frame.size.height * scale
                self.frame = frame
            } else {
                self.frame.size = self.defaultSize
            }

        }
    }
    
    func rotate(deg:CGFloat){
        self.transform = CGAffineTransformMakeRotation(radians(deg))
    }
    
    func tiltRight(){
        if !tiltedRight {
            tiltedRight = true
            rotate(-5)
        }
    }
    
    func tiltLeft() {
        if !tiltedLeft {
            tiltedLeft = true
            rotate(5)
        }
    }
    
    func untilt() {
        if tilted {
            if tiltedRight {
                tiltedRight = false
                rotate(5)
            }
            
            if tiltedLeft {
                tiltedLeft = false
                rotate(-5)
            }
        }
    }
    
    func configureAsCorrect(){
        self.backgroundColor = UIColor(patternImage: UIImage(named: "CorrectAnswerBackground"))
        self.patchTickLogo()
        self.tiltRight()
        self.tickLogoView.transform = CGAffineTransformMakeRotation(radians(-5))

    }
    
    func configureAsFalse(){
        self.backgroundColor = UIColor(patternImage: UIImage(named: "FalseAnswerBackground"))
        self.patchCrossLogo()
        self.tiltLeft()
        self.titleLabel.textColor = UIColor.whiteColor()
        self.crossLogoView.transform = CGAffineTransformMakeRotation(radians(5))
    }
    
    func patchTickLogo(){
        self.crossLogoView.bounds.origin = getPatchableOrigin()
        if let parent = self.superview {
            parent.addSubview(self.crossLogoView)
        }
    }
    
    func patchCrossLogo(){
        self.tickLogoView.bounds.origin = getPatchableOrigin()
        if let parent = self.superview {
            parent.addSubview(self.tickLogoView)
        }
    }
    
    func getPatchableOrigin() -> CGPoint {
        var xOffset = self.bounds.origin.x * 4 / 3
        var yOffset = self.bounds.origin.y * 8 / 5
        return CGPointMake(xOffset, yOffset)
    }
    
    func resetButton(){
        self.unpatchAllLogo()
        self.unshrink()
        self.backgroundColor = defaultBackgroundColour
        self.titleLabel.textColor = defaultFontColor
        self.untilt()
        self.showAndEnable(false)
        self.stopWobble()
    }
    
    func unpatchAllLogo() {
        if let parent = self.superview {
            for siblingView in parent.subviews as [UIView] {
                if siblingView === self.tickLogoView || siblingView === self.crossLogoView {
                    siblingView.removeFromSuperview()
                }
            }
        }
    }
    
    func hideAndDisable(animated: Bool){
        if self.alpha == 0 && self.enabled == false {
            return
        }
        
        if animated {
            UIView.animateWithDuration(0.5) {()->Void in
                self.alpha = 0
            }
        } else {
            self.alpha = 0
            self.disable()
        }
    }
    
    func showAndEnable(animated: Bool){
        if self.alpha == 1 && self.enabled == true {
            return
        }
        if animated {
            UIView.animateWithDuration(0.5) {()->Void in
                self.alpha = 1
            }
        } else {
            self.alpha = 1
            self.enable()
        }
    }
}
