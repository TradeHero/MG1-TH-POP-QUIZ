//
//  OverlayProgressView.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/8/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class OverlayProgressView: UIView {
    
    private enum OverlayProgressViewState{
        case Initial
        case Waiting
        case InProgress
        case Finished
    }
    
    private let kUIUpdateFrequency: NSTimeInterval = 1/25
    private var state:OverlayProgressViewState = .Initial
    private var animationProgress:CGFloat = 0
    private var timer: NSTimer? = nil
    
    /// This is #000000 with alpha equal 0.5 by default.
    var overlayColor: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    
    
    /// The ratio of the inner circle to the minimum side of OverlayProgressView,
    /// 0 ≤ innerRadiusRatio ≤ 1,
    /// Defaults to 0.6
    var innerRadiusRatio: CGFloat = 0.8
    ///  The ratio of the outer circle to the minimum side of OverlayProgressView,
    ///  0 ≤ outerRadiusRatio ≤ 1
    ///  0.7 by default
    var outerRadiusRatio: CGFloat = 0.8
    /// The float value used to for calculate the 'filled in' fraction of the inner circle,
    /// 0 ≤ progress ≤ 1
    var progress: CGFloat {
        set(pr) {
            if self._progress != pr {
                self._progress = pr < 0 ? 0 : pr > 1 ? 1 : pr
                if pr > 0 && pr < 1 {
                    self.state = .InProgress
                    self.setNeedsDisplay()
                } else if pr == 1 && self.triggersDownloadDidFinishAnimationAutomatically {
                    self.displayOperationDidFinishAnimation()
                }
            }
        }
        get { return self._progress }
    }
    
    private var _progress: CGFloat = 0.0
    /// The duration for animations displayed after calling displayOperationWillTriggerAnimation()
    /// and displayOperationDidFinishAnimation() methods.
    ///
    /// 0.25 by default.
    var stateChangeAnimationDuration: CGFloat = 0.25
    
    /// This flag indicates whether or not displayOperationDidFinishAnimation() is called when 'progress' property is set to 1,
    // defaults to true
    var triggersDownloadDidFinishAnimationAutomatically: Bool = true
    
    /// Makes the outer faded out circle radius expand until it circumscribes the DAProgressOverlayView bounds.
    func displayOperationDidFinishAnimation() {
        self.state = .Finished
        self.animationProgress = 0
        self.timer = NSTimer.scheduledTimerWithTimeInterval(kUIUpdateFrequency, target: self, selector: "update", userInfo: nil, repeats: true)
    }
    
    /// Changes radiuses of the inner and outer circles from zero to the corresponding values,
    /// calculated from 'innerRadiusRatio' and 'outerRadiusRatio' properties.
    func displayOperationWillTriggerAnimation(){
        self.state = .Finished
        self.animationProgress = 0
        self.timer = NSTimer.scheduledTimerWithTimeInterval(kUIUpdateFrequency, target: self, selector: "update", userInfo: nil, repeats: true)
        
    }
    
    
    func update() {
        let animationProgress = self.animationProgress + CGFloat(kUIUpdateFrequency)/self.stateChangeAnimationDuration
        if animationProgress > 1 {
            self.animationProgress = 1
            self.timer?.invalidate()
        } else {
            self.animationProgress = animationProgress
        }
        
        self.setNeedsDisplay()
    }
    
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect)
    {
        let width = CGRectGetWidth(rect)
        let height = CGRectGetHeight(rect)
        
        let outerRadius = self.outerRadius()
        let innerRadius = self.innerRadius()
        
        let context = UIGraphicsGetCurrentContext()
        CGContextTranslateCTM(context, width/2, height/2)
        CGContextScaleCTM(context, 1, -1)
        CGContextSetRGBFillColor(context, 0, 0, 0, 0.5)
        CGContextSetFillColorWithColor(context, overlayColor.CGColor)
        
        let path0 = CGPathCreateMutable()
        CGPathMoveToPoint(path0, nil, width/2, 0)
        CGPathMoveToPoint(path0, nil, width / 2, 0)
        CGPathAddLineToPoint(path0, nil, width / 2, height / 2)
        CGPathAddLineToPoint(path0, nil, -width / 2, height / 2)
        CGPathAddLineToPoint(path0, nil, -width / 2, 0)
        CGPathAddLineToPoint(path0, nil, (CGFloat(cosf(Float(M_PI))) * outerRadius), 0)
        CGPathAddArc(path0, nil, 0, 0, outerRadius, CGFloat(M_PI), 0, 1)
        CGPathAddLineToPoint(path0, nil, width / 2, 0)
        CGPathCloseSubpath(path0)
        
        let path1 = CGPathCreateMutable()
        var rotation = CGAffineTransformMakeScale(1, -1)
        CGPathAddPath(path1, &rotation, path0)
        
        CGContextAddPath(context, path0)
        CGContextFillPath(context)
        
        CGContextAddPath(context, path1)
        CGContextFillPath(context)
        
        if self.progress < 1 {
            let angle = 360 - ( 360 * self.progress)
            var transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
            let path2 = CGPathCreateMutable()
            
            CGPathMoveToPoint(path2, &transform, innerRadius, 0)
            CGPathAddArc(path2, &transform, 0, 0, innerRadius, 0, angle/180 * CGFloat(M_PI), true)
            CGPathAddLineToPoint(path2, &transform, 0, 0)
            CGPathAddLineToPoint(path2, &transform, innerRadius, 0)
            CGContextAddPath(context, path2)
            CGContextFillPath(context)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    func setup() {
        self.backgroundColor = UIColor.clearColor()
        self.layer.cornerRadius = self.frame.size.width * 0.5
    }
    
    private func innerRadius() -> CGFloat {
        let width = CGRectGetWidth(self.bounds)
        let height = CGRectGetHeight(self.bounds)
        
        let rad = min(width, height)/2 * self.innerRadiusRatio
        switch(self.state) {
        case .Waiting:
            return rad * self.animationProgress
        case .Finished:
            return rad + max(width, height)/(sqrt(2) - rad) * self.animationProgress
        default:
            return rad
        }
    }
    
    private func outerRadius() -> CGFloat {
        let width = CGRectGetWidth(self.bounds)
        let height = CGRectGetHeight(self.bounds)
        
        let rad = min(width, height)/2 * self.self.outerRadiusRatio
        switch(self.state) {
        case .Waiting:
            return rad * self.animationProgress
        case .Finished:
            return rad + max(width, height)/(sqrt(2) - rad) * self.animationProgress
        default:
            return rad
        }
    }
}
