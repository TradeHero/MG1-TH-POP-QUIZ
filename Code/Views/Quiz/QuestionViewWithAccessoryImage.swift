//
//  QuestionViewWithAccessoryImage.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 8/27/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class QuestionViewWithAccessoryImage: UIView {
    
    @IBOutlet  weak var questionContent: UILabel!
    
    @IBOutlet weak var accessoryImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Initialization code
    }
    
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
    
}
