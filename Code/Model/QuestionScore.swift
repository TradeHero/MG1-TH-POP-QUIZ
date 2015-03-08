//
//  QuestionScore.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 8/3/15.
//  Copyright (c) 2015 TradeHero. All rights reserved.
//

import Argo
import Runes

struct QuestionScore: JSONDecodable, DebugPrintable, DictionaryRepresentation, Equatable {
    let questionId: Int
    let rawScore: Int
    let timeTaken: NSTimeInterval
    
    static func decode(j: JSONValue) -> QuestionScore? {
        return self.create
            <^> j <| "qId"
            <*> j <| "rawScore"
            <*> j <| "timeTaken"
    }
    
    static func create(qId: Int)(rawScore: Int)(timeTaken: Double) -> QuestionScore {
        return QuestionScore(questionId: qId, rawScore: rawScore, timeTaken: timeTaken)
    }
    
    var debugDescription: String {
        return "[QuestionScore] Question ID: \(questionId), Raw Score: \(rawScore), Time taken: \(timeTaken)s\n"
    }
    
    var dictionaryRepresentation: [String: AnyObject] {
        return ["qId": questionId, "rawScore" : rawScore, "timeTaken": timeTaken]
    }
}

struct QuestionFinalScore: JSONDecodable, DebugPrintable, DictionaryRepresentation, Equatable {
    let questionId: Int
    let finalScore: Int
    
    static func decode(j: JSONValue) -> QuestionFinalScore? {
        return self.create
            <^> j <| "qId"
            <*> j <| "finalScore"
    }
    
    static func create(qId: Int)(finalScore: Int) -> QuestionFinalScore {
        return QuestionFinalScore(questionId: qId, finalScore: finalScore)
    }
    
    var debugDescription: String {
        return "[QuestionFinalScore] Question ID: \(questionId), Final Score: \(finalScore)\n"
    }
    
    var dictionaryRepresentation: [String: AnyObject] {
        return ["qId": questionId, "finalScore" : finalScore]
    }
}

func ==(lhs:QuestionFinalScore, rhs: QuestionFinalScore) -> Bool {
    return lhs.questionId == rhs.questionId &&
    lhs.finalScore == rhs.finalScore
}


func ==(lhs:QuestionScore, rhs: QuestionScore) -> Bool {
    return lhs.questionId == rhs.questionId &&
        lhs.rawScore == rhs.rawScore &&
        lhs.timeTaken == rhs.timeTaken
}