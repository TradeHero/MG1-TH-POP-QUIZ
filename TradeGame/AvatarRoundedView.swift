//
//  AvatarRoundedView.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/1/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit
import Views

@IBDesignable
class AvatarRoundedView: DesignableRoundedView {

    @IBInspectable
    var image : UIImage? {
    didSet {
        refreshImage()
    }
    }
    
    override init(frame: CGRect) {
        avatarImageView = UIImageView(frame: CGRectZero)
        super.init(frame: frame)
        addSubview(avatarImageView)
        setup()
    }
    
    required init(coder aDecoder: NSCoder!) {
        avatarImageView = UIImageView(frame: CGRectZero)
        super.init(coder: aDecoder)
        addSubview(avatarImageView)
        setup()
    }

    var avatarImageView: UIImageView
    
    override func prepareForInterfaceBuilder() {
        setup()
    }
    
    override func setup() {
        if image == nil {
            image = UIImage(named: "EmptyAvatar")
        }
        super.setup()
    }

    func refreshImage(){
        avatarImageView.image = image != nil ? prepareImage(image!) : nil
        backgroundColor = image != nil ? nil : UIColor.whiteColor()
    }
    
    
    func prepareImage(source:UIImage, saturation: CGFloat = 1) -> UIImage {
        var size = source.size
        var magnitude = min(source.size.width, source.size.height)
        var bounds = CGRectMake(0, 0, magnitude, magnitude)
        
        return imageByDrawing(bounds.size, scale: source.scale) {
            UIBezierPath(ovalInRect: bounds).addClip()
            source.drawAtPoint(CGPointMake((magnitude-source.size.width)/2, (magnitude - source.size.height)/2))
            UIColor(white: 1.0, alpha: 1.0 - saturation).set()
            UIRectFillUsingBlendMode(bounds, kCGBlendModeColor)
        }
    }
    
    func imageByDrawing(size: CGSize, scale: CGFloat, closure: () -> ()) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        closure()
        var result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    
    }
    
    override func layoutSubviews() {
        avatarImageView.frame = bounds
        super.layoutSubviews()
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect)
    {
        // Drawing code
    }
    */

}
