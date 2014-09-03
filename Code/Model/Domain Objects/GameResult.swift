//
//  GameResult.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/27/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

typealias QuestionResultDetail = (id:Int, rawScore:Int, time:CGFloat)
typealias QuestionResultFinalDetail = (id:Int, bonus:Int)

final class GameResult {
   
    var gameId: Int!
    var userId: Int!
    var score: Int!
    var details: String!
    var finalScores: String!
    
    lazy var rawScore: Int = {
        var rScore = 0
        for detail in self.resultDetails {
            rScore += detail.rawScore
        }
        return rScore
        }()
    
    lazy var questionCorrect: Int = {
        var qCorrect = 0
        for detail in self.resultDetails {
            if detail.rawScore > 0 {
                qCorrect++
            }
        }
        return qCorrect
    }()
    
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
    
    lazy var resultFinalScores: [QuestionResultFinalDetail] = {
        var qrfd: [QuestionResultFinalDetail] = []
        let details = self.details.componentsSeparatedByString("|")
        
        for detail in details {
            let dComps = detail.componentsSeparatedByString(", ")
            qrfd.append((id:dComps[0].intValue, bonus:dComps[1].intValue))
        }
        
        return qrfd
        }()
    
    private var submittedAtUtcString:String!
    
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
            self.finalScores = d as String
        }
        
        if let date: AnyObject = resultDTO["submittedAtUtc"] {
            self.submittedAtUtcString = date as String
        }
    }
}
