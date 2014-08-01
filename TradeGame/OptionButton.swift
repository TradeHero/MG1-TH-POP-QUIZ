//
//  OptionButton.swift
//  TradeGame
//
//  Created by Ryne Cheow on 7/30/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit
import Views

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
}
