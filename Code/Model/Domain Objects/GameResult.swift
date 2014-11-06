//
//  GameResult.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 8/27/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

typealias QuestionResultDetail = (id:Int, rawScore:Int, time:Float)
typealias QuestionResultFinalDetail = (id:Int, finalScore:Int)

final class GameResult: NSCoding {
    private let kGameResultGameIDKey = "GameResultGameID"
    private let kGameResultUserIDKey = "GameResultUserID"
    private let kGameResultScoreKey = "GameResultScore"
    private let kGameResultDetailsKey = "GameResultDetails"
    private let kGameResultExtraDetailsKey = "GameResultExtraDetails"
    private let kGameResultHintsUsedKey = "GameResultHintsUsed"
    private let kGameResultHighestComboKey = "GameResultHighestCombo"
    private let kGameResultSubmittedAtUtcStringKey = "GameResultSubmittedAtUtcString"
    
    var gameId: Int! //NSCoding
    var userId: Int! //NSCoding
    var score: Int! //NSCoding
    var details: String! //NSCoding
    var extraDetails: String! //NSCoding
    var hintsUsed: Int! //NSCoding
    var highestCombo: Int! //NSCoding
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(gameId, forKey: kGameResultGameIDKey)
        
        aCoder.encodeInteger(userId, forKey: kGameResultUserIDKey)
        
        aCoder.encodeInteger(score, forKey: kGameResultScoreKey)
        
        aCoder.encodeObject(details, forKey: kGameResultDetailsKey)
        
        aCoder.encodeObject(extraDetails, forKey: kGameResultExtraDetailsKey)
        
        aCoder.encodeInteger(hintsUsed, forKey: kGameResultHintsUsedKey)
        
        aCoder.encodeInteger(highestCombo, forKey: kGameResultHighestComboKey)
        
        aCoder.encodeObject(submittedAtUtcString, forKey: kGameResultSubmittedAtUtcStringKey)
    }
    
    
    
    var rawScore: Int {
        var rScore = 0
        for detail in self.resultDetails {
            rScore += detail.rawScore
        }
        return rScore
    }
    
    var finalScore: Int {
        if let rxd = self.resultExtraDetails {
            var fScore = 0
            for detail in rxd {
                fScore += detail.finalScore
            }
            return fScore
        } else {
            return rawScore
        }
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
    
    private var submittedAtUtcString:String! //NSCoding
    
    lazy var submittedAt: NSDate! = {
        return DataFormatter.sharedClient.dateFormatter.dateFromString(self.submittedAtUtcString)
    }()
    
    lazy var resultDetails: [QuestionResultDetail] = {
        var qrd: [QuestionResultDetail] = []
        let details = self.details.componentsSeparatedByString("|")
        
        for detail in details {
            let dComps = detail.componentsSeparatedByString(", ")
            qrd.append((id:dComps[0].intValue, rawScore:dComps[1].intValue, time:(dComps[2] as NSString).floatValue))
        }
        
        return qrd
        }()
    
    lazy var resultExtraDetails: [QuestionResultFinalDetail]! = {
        if self.extraDetails == nil { return nil }
        var qrfd: [QuestionResultFinalDetail] = []
        let details = self.extraDetails.componentsSeparatedByString("|")
        
        for detail in details {
            let dComps = detail.componentsSeparatedByString(", ")
            qrfd.append((id:dComps[0].intValue, finalScore:dComps[1].intValue))
        }
        
        return qrfd
        }()
    
    
    init(gameId:Int, resultDTO:[String: AnyObject]) {
        self.gameId = gameId
        
        if let uid: AnyObject = resultDTO["userId"] {
            self.userId = uid as Int
        }
        
        if let sc: AnyObject = resultDTO["score"] {
            self.score = sc as Int
        }
        
        if let d: AnyObject = resultDTO["details"] {
            self.details = d as String
        }
        
        if let d: AnyObject = resultDTO["finalScores"] {
            self.extraDetails = d as String
        }
        
        if let date: AnyObject = resultDTO["submittedAtUtc"] {
            self.submittedAtUtcString = date as String
        }
        
        if let cs: AnyObject = resultDTO["correctStreak"] {
            self.highestCombo = cs as Int
        }
        
        if let h: AnyObject = resultDTO["hintsUsed"] {
            self.hintsUsed = h as Int
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        self.gameId = aDecoder.decodeIntegerForKey(kGameResultGameIDKey)
        
        self.userId = aDecoder.decodeIntegerForKey(kGameResultUserIDKey)
        
        self.score = aDecoder.decodeIntegerForKey(kGameResultScoreKey)
        
        self.details = aDecoder.decodeObjectForKey(kGameResultDetailsKey) as String
        
        self.extraDetails = aDecoder.decodeObjectForKey(kGameResultExtraDetailsKey) as String
        
        self.hintsUsed = aDecoder.decodeIntegerForKey(kGameResultHintsUsedKey)
        
        self.highestCombo = aDecoder.decodeIntegerForKey(kGameResultHighestComboKey)
        
        self.submittedAtUtcString = aDecoder.decodeObjectForKey(kGameResultSubmittedAtUtcStringKey) as String
        
    }
}
