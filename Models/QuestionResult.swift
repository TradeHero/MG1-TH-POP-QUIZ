//
//  QuestionResult.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/7/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

public class QuestionResult {
    public let questionNumber: Int!
    public let isAnswerCorrect: Bool!
    
    public init(qNum: Int, isCorrect:Bool){
        questionNumber = qNum
        isAnswerCorrect = isCorrect
    }
    
    public func toDictionary() -> [String: Int]{
        return ["question": questionNumber, "correct" : isAnswerCorrect ? 1 : 0]
    }
}
