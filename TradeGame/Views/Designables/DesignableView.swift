//
//  DesignableView.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/19/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

@IBDesignable
class DesignableView: UIView {

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
   
    @IBInspectable
    var backgroundImage: UIImage! = nil {
        didSet {
            if backgroundImage != nil {
                self.backgroundColor = UIColor(patternImage: self.backgroundImage)
            } else {
                self.backgroundColor = UIColor.clearColor()
            }
        }
    }
    
}
