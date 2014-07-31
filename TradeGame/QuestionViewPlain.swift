//
//  QuestionViewPlain.swift
//  TradeGame
//
//  Created by Ryne Cheow on 7/30/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

public class QuestionViewPlain: UIView {

    @IBOutlet public weak var questionContent: UILabel!
    
    public init(frame: CGRect) {
        super.init(frame: frame)
        // Initialization code
    }

    public init(coder aDecoder: NSCoder!){
        super.init(coder: aDecoder)
    }
}
