//
//  ScoreProgressView.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/4/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class ScoreProgressView: DesignableRoundedRectangleView {
    
    var fillColor:UIColor!
    
    required init(coder aDecoder: NSCoder) {
        coloredView = UIView(frame: CGRectZero)
        super.init(coder: aDecoder)
        backgroundColor = UIColor.blackColor()
        coloredView = UIView(frame: CGRectMake(0, self.frame.height, self.frame.width, self.frame.height))
    }
    
    var capacity: Int = 100 {
    didSet{
        prepareToDrawProgress()
    }
    }
    
    var value:Int = 0{
    didSet{
        prepareToDrawProgress()
    }
    }
    
    var ratio: Double {
    
    get {
        return Double(value)/Double(capacity)
    }
        
    set(newRatio){
        let x = newRatio * Double(capacity)
        value = Int(x)
    }
    
    }
    
    var coloredView: UIView
    
    func prepareToDrawProgress(){
        coloredView.backgroundColor = fillColor
        UIView.animateWithDuration(NSTimeInterval(1.0), animations: {() -> Void in
            
            }, completion:nil)
    }
    
}
