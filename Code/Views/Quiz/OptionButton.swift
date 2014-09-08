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
    
    private var defaultCenter: CGPoint!
    
    private var defaultFont: UIFont!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Initialization code
    }
    
    var is_answer: Bool = false
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.tickLogoView.image = UIImage(named: "QuizTickIcon")
        self.crossLogoView.image = UIImage(named: "QuizCrossIcon")
    }
    var trendingTopLayerView: OptionButtonAccessoryImageLayer!
    
    var wobbling: Bool = false
    
    var isShrinked: Bool = false
    
    var tilted: Bool = false
    
    var tickLogoView = UIImageView(frame: CGRectMake(0, 0, 59, 56))
    
    var crossLogoView = UIImageView(frame: CGRectMake(0, 0, 51, 51))
    
    var accessoryImage: UIImage! {
        didSet {
            if let img = accessoryImage {
                //                self.setImage(img, forState: .Normal)
                self.configureAsTrendingStyle()
            }
        }
    }
    var labelText: String = "" {
        didSet {
            func getLongestWordLength(stringArray:[String]) -> Int{
                var maxLength: Int = 0
                var length:Int = 0
                for string in stringArray as [NSString]{
                    length = string.length
                    if length > maxLength {
                        maxLength = length
                    }
                }
                return maxLength
            }
            
            func getNumberOfWordsWithWordCountApproximately(stringArray:[String], count:Int) -> Int{
                var c: Int = 0
                for string in stringArray as [NSString]{
                    let length = string.length
                    if abs(length - count) < 3 {
                        ++c
                    }
                }
                return c
            }
            self.setTitle(self.labelText, forState: .Normal)
            let txt = labelText
            let txtComponents = labelText.componentsSeparatedByString(" ")
            let wordCount = txtComponents.count
            
            let longestWordLength = getLongestWordLength(txtComponents)
            let longestWordCount = getNumberOfWordsWithWordCountApproximately(txtComponents, longestWordLength)
            
            if wordCount > 0 {
                if longestWordLength > 7 { //chunky
                    if longestWordCount > 3 { //long
                        self.titleLabel?.lineBreakMode = .ByClipping
                    } else { // short
                        self.titleLabel?.lineBreakMode = .ByWordWrapping
                    }
                } else { // simple
                    if wordCount > 5 { //long
                        self.titleLabel?.lineBreakMode = .ByClipping
                    } else { // short
                        self.titleLabel?.lineBreakMode = .ByWordWrapping
                    }
                }
            }
            
        }
    }
    
    func startWobble(){
        if !self.wobbling {
            self.wobbling = true
            self.transform = CGAffineTransformRotate(CGAffineTransformIdentity,radians(-3))
            
            UIView.animateWithDuration(0.1, delay: 0, options: .AllowUserInteraction | .Repeat | .Autoreverse, animations: {
                self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, radians(3))
                }, completion: nil)
        }
    }
    
    func stopWobble() {
        if self.wobbling {
            self.wobbling = false
            UIView.animateWithDuration(0.1, delay: 0, options: .AllowUserInteraction | .BeginFromCurrentState | .CurveLinear, animations: {
                self.transform = CGAffineTransformIdentity
                }, completion: nil)
        }
    }
    
    func shrink() {
        if !isShrinked {
            isShrinked = true
            var rect = self.bounds
            var center = self.center
            self.defaultSize = self.frame.size
            self.defaultCenter = self.center
            self.defaultFont = self.titleLabel?.font
            
            self.titleLabel?.font = self.defaultFont.fontWithSize(14)
            rect.size.width = self.frame.size.width * 0.8
            rect.size.height = self.frame.size.height * 0.8
            
            if self.trendingTopLayerView != nil {
                var t = CGAffineTransformMakeScale(0.8, 0.8)
                t = CGAffineTransformTranslate(t, -0.1 * self.trendingTopLayerView.frame.size.width, -0.1 * self.trendingTopLayerView.frame.size.height)
                self.trendingTopLayerView.transform = t
            }
            
            UIView.animateWithDuration(0.1, animations: {
                self.bounds = rect
            })
            
        }
    }
    
    func unshrink() {
        if isShrinked{
            isShrinked = false
            self.bounds.size = self.defaultSize
            self.center = self.defaultCenter
            self.titleLabel?.font = self.defaultFont
            if self.trendingTopLayerView != nil {
                self.trendingTopLayerView.transform = CGAffineTransformIdentity
            }
        }
    }
    
    func rotate(deg:CGFloat){
        self.transform = CGAffineTransformRotate(CGAffineTransformIdentity,radians(deg))
    }
    
    func tiltRight(){
        if !tilted {
            tilted = true
            rotate(-3)
            self.tickLogoView.transform = CGAffineTransformMakeRotation(radians(-3))
            if self.trendingTopLayerView != nil {
                self.trendingTopLayerView.titleLabel.textColor = UIColor.whiteColor()
            }
        }
    }
    
    func tiltLeft() {
        if !tilted {
            tilted = true
            rotate(3)
            self.crossLogoView.transform = CGAffineTransformMakeRotation(radians(3))
            if self.trendingTopLayerView != nil {
                self.trendingTopLayerView.titleLabel.textColor = UIColor.whiteColor()
            }
            
        }
    }
    
    func untilt() {
        if tilted {
            tilted = false
            self.transform = CGAffineTransformIdentity
            self.tickLogoView.transform = CGAffineTransformIdentity
            self.crossLogoView.transform = CGAffineTransformIdentity
        }
    }
    
    func configureAsCorrect(){
        self.backgroundColor = UIColor(patternImage: UIImage(named: "CorrectAnswerBackground"))
        self.patchTickLogo()
        self.tiltRight()
        self.titleLabel?.textColor = UIColor.whiteColor()
    }
    
    func configureAsFalse(){
        self.backgroundColor = UIColor(patternImage: UIImage(named: "FalseAnswerBackground"))
        self.patchCrossLogo()
        self.tiltLeft()
        self.titleLabel?.textColor = UIColor.whiteColor()
        
    }
    
    func patchCrossLogo(){
        self.crossLogoView.frame.origin = getPatchableOrigin()
        var bounds = self.crossLogoView.bounds
        var bounds2 = self.crossLogoView.bounds
        if let parent = self.superview {
            parent.addSubview(self.crossLogoView)
        }
        bounds.size.width = 0
        bounds.size.height = 0
        self.crossLogoView.bounds = bounds
        UIView.animateWithDuration(0.2) {
            self.crossLogoView.bounds = bounds2
        }
    }
    
    func patchTickLogo(){
        self.tickLogoView.frame.origin = getPatchableOrigin()
        var bounds = self.tickLogoView.bounds
        var bounds2 = self.tickLogoView.bounds
        if let parent = self.superview {
            parent.addSubview(self.tickLogoView)
        }
        bounds.size.width = 0
        bounds.size.height = 0
        self.tickLogoView.bounds = bounds
        UIView.animateWithDuration(0.2) {
            self.tickLogoView.bounds = bounds2
        }
    }
    
    func getPatchableOrigin() -> CGPoint {
        var xOffset = self.frame.origin.x + self.frame.size.width * 2 / 3
        var yOffset = self.frame.origin.y + self.frame.size.height * 3 / 5
        return CGPointMake(xOffset, yOffset)
    }
    
    func resetButton(){
        self.configureAsNormalStyle()
        self.unpatchAllLogo()
        self.unshrink()
        self.backgroundColor = defaultBackgroundColour
        self.titleLabel?.textColor = defaultFontColor
        self.untilt()
        self.stopWobble()
        self.showAndEnable(false)
        self.disable()
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
            UIView.animateWithDuration(0.5) {
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
            UIView.animateWithDuration(0.5) {
                self.alpha = 1
            }
        } else {
            self.alpha = 1
            self.enable()
        }
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.imageView?.image = UIImage(named:"TradeHeroFriendsBullIcon")
    }
    
    private func configureAsTrendingStyle(){
        
        if let b = self.titleLabel?.isSubviewOf(self) {
            if b {
                self.titleLabel?.removeFromSuperview()
            }
        }
        
        //        self.imageView.hidden = true
        trendingTopLayerView = NSBundle.mainBundle().loadNibNamed("OptionButtonAccessoryImageLayer", owner: self, options: nil)[0] as OptionButtonAccessoryImageLayer
        trendingTopLayerView.titleLabel.text = self.labelText
        trendingTopLayerView.imageView.image = self.accessoryImage
        trendingTopLayerView.userInteractionEnabled = false
        self.addSubview(trendingTopLayerView)
        //        self.bringSubviewToFront(topLayer)
    }
    
    private func configureAsNormalStyle() {
        
        if let b = self.titleLabel?.isSubviewOf(self) {
            if !b {
                self.addSubview(self.titleLabel!)
            }
        }
        self.titleLabel?.hidden = false
        self.imageView?.hidden = false
        for view in self.subviews as [UIView]{
            if view is OptionButtonAccessoryImageLayer {
                view.removeFromSuperview()
            }
        }
        trendingTopLayerView = nil
    }
    
    func configureButtonWithContent(stringContent:String, imageContent:UIImage!){
        self.labelText = stringContent
        if let img = imageContent {
            self.accessoryImage = img.replaceWhiteinImageWithTransparency()
        }
    }
}


