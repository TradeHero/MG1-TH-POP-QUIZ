//
//  AnswerOption.swift
//  TradeGame
//
//  Created by Ryne Cheow on 7/30/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class AnswerOption {
    var optionContent: String = ""
    
    var optionImageContent: UIImage? = nil
    
    init(stringContent:String){
        optionContent = stringContent
    }
    
    init(imageContent:UIImage){
        optionImageContent = imageContent
    }
}
