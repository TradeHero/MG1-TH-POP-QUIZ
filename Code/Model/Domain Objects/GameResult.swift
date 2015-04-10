//
//  GameResult.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 8/3/15.
//  Copyright (c) 2015 TradeHero. All rights reserved.
//

import Runes
import Argo

struct GameResult: JSONDecodable, DebugPrintable, Equatable {

    let gameId: Int

    let hintsUsed: Int

    let correctStreak: Int

    let score: Int

    let user: User

    let finalResultDetails: [QuestionFinalScore]?

    let resultDetails: [QuestionScore]

    let submittedAt: NSDate

    var finalScore: Int? {
        var fScore = 0
        if let frd = finalResultDetails {
            for detail in frd {
                fScore += detail.finalScore
            }
            return fScore
        }
        return nil
    }

    var rawScore: Int {
        var fScore = 0
        for detail in resultDetails {
            fScore += detail.rawScore
        }
        return fScore
    }

    var questionCorrect: Int {
        var qCorrect = 0
        for detail in self.resultDetails {
            if detail.rawScore > 0 {
                qCorrect++
            }
        }
        return qCorrect
    }

    static func decode(j: JSONValue) -> GameResult? {
        return self.create
                <^> j <| "gameId"
                <*> j <| "hintsUsed"
                <*> j <| "correctStreak"
                <*> j <| "score"
                <*> j <| "user"
                <*> j <||? "finalResultDetails"
                <*> j <|| "resultDetails"
                <*> j <| "submittedAtUtc"
    }

    static func create(gameId: Int)(hintsUsed: Int)(correctStreak: Int)(score: Int)(user: User)(finalResultDetails: [QuestionFinalScore]?) (resultDetails: [QuestionScore])(submittedAtUtc: String) -> GameResult {

        var date = DataFormatter.shared.dateFormatter.dateFromString(submittedAtUtc)!

        return GameResult(gameId: gameId, hintsUsed: hintsUsed, correctStreak: correctStreak, score: score, user: user, finalResultDetails: finalResultDetails, resultDetails: resultDetails, submittedAt: date)
    }

    var debugDescription: String {
        return ""
    }

    var dictionaryRepresentation: [String:AnyObject] {
        var dict: [String:AnyObject] = ["gameId": gameId, "hintsUsed": hintsUsed, "correctStreak": correctStreak, "score": score, "user": user.dictionaryRepresentation, "resultDetails": resultDetails.map {
            $0.dictionaryRepresentation
        }];

        if let fs = finalResultDetails {
            dict.updateValue(fs.map {
                $0.dictionaryRepresentation
            }, forKey: "finalResultDetails")
        }

        return dict
    }

}

func ==(lhs: GameResult, rhs: GameResult) -> Bool {

    var finalResultEq = true

    if let lhsFinal = lhs.finalResultDetails {
        //if not nil
        if let rhsFinal = rhs.finalResultDetails {
            //if not nil
            finalResultEq == finalResultEq && lhsFinal == rhsFinal //true if not nil value equals
        } else {
            finalResultEq == finalResultEq && false //false if rhs not nil
        }
    } else {
        //if lhs nil
        if let rhsFinal = rhs.finalResultDetails {
            //rhs not nil, false
            finalResultEq == finalResultEq && false
        } else {
            //rhs nil, true
            finalResultEq == finalResultEq && true
        }
    }


    return lhs.gameId == rhs.gameId &&
            lhs.hintsUsed == rhs.hintsUsed &&
            lhs.correctStreak == rhs.correctStreak &&
            lhs.score == rhs.score &&
            lhs.user == rhs.user &&
            lhs.resultDetails == rhs.resultDetails && finalResultEq
}
