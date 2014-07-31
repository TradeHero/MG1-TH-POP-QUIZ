//
//  QuestionWithImage.swift
//  TradeGame
//
//  Created by Ryne Cheow on 7/30/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class QuestionViewWithImage: UIView {

    @IBOutlet public weak var questionContent: UILabel!
    @IBOutlet public weak var imageView: UIImageView!
    
    public init(frame: CGRect) {
        super.init(frame: frame)
        // Initialization code
    }
    
    public init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
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
