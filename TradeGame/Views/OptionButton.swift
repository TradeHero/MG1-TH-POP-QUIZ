//
//  OptionButton.swift
//  TradeGame
//
//  Created by Ryne Cheow on 7/30/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

func radians(deg:Double) -> Double {
    return (deg * M_PI)/180.0
}

@IBDesignable
class OptionButton: DesignableButton {
    
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

    
    func startWobble(){
        self.wobbling = true
        self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, CGFloat(radians(-3)))
        
        UIView.animateWithDuration(0.1, delay: 0, options: UIViewAnimationOptions.AllowUserInteraction | UIViewAnimationOptions.Repeat | UIViewAnimationOptions.Autoreverse, animations: {() -> Void in
                self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, CGFloat(radians(3)))
            }, completion: nil)
    }
    
    func stopWobble() {
        self.wobbling = false
        UIView.animateWithDuration(0.1, delay: 0, options: UIViewAnimationOptions.AllowUserInteraction | UIViewAnimationOptions.BeginFromCurrentState | UIViewAnimationOptions.CurveLinear, animations: {() -> Void in
            self.transform = CGAffineTransformIdentity
            }, completion: nil)
    }
}
