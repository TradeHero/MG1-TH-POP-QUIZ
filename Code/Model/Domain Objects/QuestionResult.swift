//
//  QuestionResult.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 8/25/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import Foundation

final class QuestionResult {
    var questionId: Int
    var timeTaken: Float
    var isCorrect: Bool = false
    var rawScore: Int
    var bonus: Int!
    var finalScore: Int!

    init(questionID: Int, timeTaken: Float, correct: Bool, score: Int) {
        self.questionId = questionID
        self.timeTaken = timeTaken
        self.isCorrect = correct
        self.rawScore = score
    }
}

extension QuestionResult: Printable {
    var description: String {
        var d = "{\n"
        d += "Question ID: \(self.questionId)\n"
        d += "Time taken: \(self.timeTaken) sec(s)\n"
        d += "Correct: \(self.isCorrect)\n"
        d += "Raw score: \(self.rawScore)\n"
        if self.bonus != nil {
            d += "Bonus: \(self.bonus)\n"
        }
        if self.finalScore != nil {
            d += "Final Score: \(self.finalScore)\n"
        }
        d += "\n}"
        return d
    }
}