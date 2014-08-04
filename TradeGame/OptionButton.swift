//
//  OptionButton.swift
//  TradeGame
//
//  Created by Ryne Cheow on 7/30/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit
import Views

func radians(deg:Double) -> Double {
    return (deg * M_PI)/180.0
}

@IBDesignable
public class OptionButton: DesignableButton {
    
    init(frame: CGRect) {
        super.init(frame: frame)
        // Initialization code
    }
    
    public var option:String? = nil {
    didSet{
        self.setTitle(option, forState: UIControlState.Normal)    }
    }
    
    public var is_answer: Bool = false
    
    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    func startWobble(){
        self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, CGFloat(radians(-3)))
        
        UIView.animateWithDuration(0.1, delay: 0, options: UIViewAnimationOptions.AllowUserInteraction | UIViewAnimationOptions.Repeat | UIViewAnimationOptions.Autoreverse, animations: {() -> Void in
                self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, CGFloat(radians(3)))
            }, completion: nil)
    }
    
    func stopWobble() {
        UIView.animateWithDuration(0.5, delay: 1, options: UIViewAnimationOptions.AllowUserInteraction | UIViewAnimationOptions.BeginFromCurrentState | UIViewAnimationOptions.CurveLinear, animations: {() -> Void in
            self.transform = CGAffineTransformIdentity
            }, completion: nil)
    }
}
