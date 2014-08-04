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
    @IBOutlet public weak var imageView: EditableImageView!
    
    public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup(){
        
    }
}
