//
//  QuestionResult.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/25/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import Foundation

class QuestionResult {
    var questionId: Int!
    var timeTaken: CGFloat!
    var isCorrect: Bool!
    
    init(questionID: Int, timeTaken:CGFloat, correct:Bool) {
        self.questionId = questionID
        self.timeTaken = timeTaken
        self.isCorrect = correct
    }
}

extension QuestionResult: Printable {
    var description: String {
        var d = "{\n"
            d += "Question ID: \(self.questionId)\n"
            d += "Time taken: \(self.timeTaken) sec(s)\n"
            d += "Correct: \(self.isCorrect)\n"
            d += "\n}"
        return d
    }
}