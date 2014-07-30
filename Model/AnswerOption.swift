//
//  AnswerOption.swift
//  TradeGame
//
//  Created by Ryne Cheow on 7/30/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

public class AnswerOption {
    public var optionContent: String = ""
    
    public var optionImageContent: UIImage? = nil
    
    public init(stringContent:String){
        optionContent = stringContent
    }
    
    public init(imageContent:UIImage){
        optionImageContent = imageContent
    }
}
