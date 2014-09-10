//
//  GameResult.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/27/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

typealias QuestionResultDetail = (id:Int, rawScore:Int, time:CGFloat)
typealias QuestionResultFinalDetail = (id:Int, finalScore:Int)

final class GameResult {
    
    var gameId: Int!
    var userId: Int!
    var score: Int!
    var details: String!
    var extraDetails: String!
    var hintsUsed: Int!
    var highestCombo: Int!
    
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
    
    private var submittedAtUtcString:String!
    
    lazy var submittedAt: NSDate! = {
        let df = NSDateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        df.timeZone = NSTimeZone(name: "UTC")
        return df.dateFromString(self.submittedAtUtcString)
        }()
    
    lazy var resultDetails: [QuestionResultDetail] = {
        var qrd: [QuestionResultDetail] = []
        let details = self.details.componentsSeparatedByString("|")
        
        for detail in details {
            let dComps = detail.componentsSeparatedByString(", ")
            qrd.append((id:dComps[0].intValue, rawScore:dComps[1].intValue, time:dComps[2].CGFloatValue))
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
    }
}
