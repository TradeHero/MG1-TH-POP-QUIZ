//
//  EditableImageView.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/4/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

public class EditableImageView: UIImageView {

    private var matteImage: UIImage!
    
    public init(frame: CGRect) {
        super.init(frame: frame)
        // Initialization code
        self.contentMode = UIViewContentMode.ScaleAspectFit
    }
    
    public init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        self.contentMode = UIViewContentMode.ScaleAspectFit
        self.backgroundColor = UIColor.whiteColor()
    }
    
    public func mosaic(tileSize:Int){
        self.image = UIImage(CGImage: matteImage.CGImage).mosaicEffectOnImage(tileSize)
        
    }

    public func blur(){
        
    }
    
    public func reset(){
//        self.image = matteImage
        UIView.transitionWithView(self, duration: 1, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {() -> Void in
            self.image = self.matteImage
            }, completion: nil)
    }
    
    public var presetImage : UIImage! {
    didSet{
        self.image = presetImage.transparencyToWhiteMatte()
        matteImage = UIView.rasterizeView(self)
        self.image = matteImage
    }
    }

}
