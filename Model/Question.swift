//
//  Question.swift
//  TradeGame
//
//  Created by Ryne Cheow on 7/30/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

public class Question {
    public var questionContent:String

    public var isWithImage:Bool{
    get{
        return questionImage != nil
    }
    }

    public var options: OptionSet
    
    public var questionImage:UIImage? = nil
    
    public init(content:String, optionSet:OptionSet, image:UIImage?) {
        questionContent = content
        options = optionSet
        if let img = image {
            questionImage = img
        }
    }
}
