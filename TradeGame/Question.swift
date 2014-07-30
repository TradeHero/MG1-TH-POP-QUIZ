//
//  Question.swift
//  TradeGame
//
//  Created by Ryne Cheow on 7/30/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

public class Question {
    var questionContent:String

    var isWithImage:Bool{
    get{
        return questionImage != nil
    }
    }

    var options: AnswerOptionSet
    
    var questionImage:UIImage? = nil
    
    init(content:String, optionSet:AnswerOptionSet, image:UIImage?) {
        questionContent = content
        options = optionSet
        if let img = image {
            questionImage = img
        }
    }
}
