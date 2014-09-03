//
//  Game.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/7/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

final class Game {
    
    let gameID: Int!
    private let createdAtUTCStr: String!
    
    var initiatingPlayer: THUser!
    
    var opponentPlayer: THUser!
    
    var initiatingPlayerID: Int!
    
    var opponentPlayerID: Int!
    
    var initiatingPlayerResult: GameResult!
    
    var opponentPlayerResult: GameResult!
    
    var isGameCompletedByChallenger: Bool {
        return initiatingPlayerResult != nil
    }
    
    var isGameCompletedByBothPlayer: Bool {
        return initiatingPlayerResult != nil && opponentPlayerResult != nil
    }

    lazy var createdAt: NSDate! = {
        let df = NSDateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        df.timeZone = NSTimeZone(name: "UTC")
        return df.dateFromString(self.createdAtUTCStr)
        }()
    
    var questionSet: [Question]!
    
    init(id: Int, createdAtUTCStr:String, questionSet:[Question]) {
        self.gameID = id
        self.createdAtUTCStr = createdAtUTCStr
        self.questionSet = questionSet
    }
    
    init(gameDTO:[String: AnyObject]){
        if let cuid: AnyObject = gameDTO["createdByUserId"] {
            self.initiatingPlayerID = cuid as Int
        }
        
        if let opuid: AnyObject = gameDTO["opponentUserId"] {
            self.opponentPlayerID = opuid as Int
        }
        
        if let id: AnyObject = gameDTO["id"] {
            self.gameID = id as Int
        }
        
        if let s: AnyObject = gameDTO["createdAtUtc"] {
            self.createdAtUTCStr = s as String
        }
        
        var qSet: [Question] = []
        if let qs: AnyObject = gameDTO["questionSet"] {
            let questionJSON = qs as [AnyObject]
            for q in questionJSON {
                if let questionDTO = q as? [String: AnyObject] {
                    qSet.append(Question(questionDTO: questionDTO))
                }
            }
            self.questionSet = qSet
        }
    }
    
    init(compactGameDTO:[String: AnyObject]){
        if let cuid: AnyObject = compactGameDTO["createdByUserId"] {
            self.initiatingPlayerID = cuid as Int
        }
        
        if let opuid: AnyObject = compactGameDTO["opponentUserId"] {
            self.opponentPlayerID = opuid as Int
        }
        
        if let id: AnyObject = compactGameDTO["id"] {
            self.gameID = id as Int
        }
        
        if let s: AnyObject = compactGameDTO["createdAtUtc"] {
            self.createdAtUTCStr = s as String
        }
        
        self.questionSet = nil
    }
    
    func fetchUsers(completionHandler:()->Void) {
        weak var wself = self
        NetworkClient.sharedClient.fetchUser(opponentPlayerID, force: true) {
            var sself = wself!
            if let u = $0 {
                sself.opponentPlayer = u
            }
            
            NetworkClient.sharedClient.fetchUser(sself.initiatingPlayerID, force: true) {
                if let u = $0 {
                    sself.initiatingPlayer = u
                }
                
                completionHandler()
            }
        }
    }
    
    func fetchResults(completionHandler:()->Void){
//        weak var wself = self
        
        NetworkClient.sharedClient.getResultForGame(self.gameID) {
//            var sself = wself!
            if let cResults = $0.challengerResult {
                if self.initiatingPlayer.userId == cResults.userId {
                    self.initiatingPlayerResult = cResults
                } else {
                    self.opponentPlayerResult = cResults
                }
            }
            
            if let oResults = $0.opponentResult {
                if self.opponentPlayerResult.userId == oResults.userId {
                    self.opponentPlayerResult = oResults
                } else {
                    self.initiatingPlayerResult = oResults
                }
            }
            
            completionHandler()
        }
    }
}

extension Game: Printable {
    var description : String {
        var d = "{\nGame details:\n"
            d += "ID: \(gameID)\n"
            d += "Created At: \(createdAt)\n"
            d += "Initiator: \(initiatingPlayer)\n"
            d += "Opponent: \(opponentPlayer)\n"
            d += "Questions: "
            var i:Int = 0
            for q in questionSet {
                d += "Question \(++i): \(q)"
            }
            d += "\n}\n"
            return d
    }
}