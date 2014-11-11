//
//  Game.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 8/7/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

final class Game {
    
    let gameID: Int!
    
    private var createdAtUTCStr: String!
    
    var initiatingPlayer: THUser!
    
    var opponentPlayer: THUser!
    
    var initiatingPlayerID: Int!
    
    var opponentPlayerID: Int!
    
    var initiatingPlayerResult: GameResult!
    
    var opponentPlayerResult: GameResult!
    
    var expired = false
    
    var rejectedByOpponent = false
    
    var lastNudgedOpponentAtUTCStr: String!
    
    var lastNudgedOpponentAt: NSDate! {
        if let str = lastNudgedOpponentAtUTCStr {
            return DataFormatter.shared.dateFormatter.dateFromString(str)
        }
        return nil
    }
    
    var isGameCompletedByChallenger: Bool {
        return initiatingPlayerResult != nil
    }
    
    var isGameCompletedByOpponent: Bool {
        return opponentPlayerResult != nil
    }
    
    var isGameCompletedByBothPlayer: Bool {
        return initiatingPlayerResult != nil && opponentPlayerResult != nil
    }

    lazy var createdAt: NSDate! = {
        return DataFormatter.shared.dateFormatter.dateFromString(self.createdAtUTCStr)
    }()
    
    var questionSet: [Question]!
    
    init(id: Int, createdAtUTCStr:String, questionSet:[Question]) {
        self.gameID = id
        self.createdAtUTCStr = createdAtUTCStr
        self.questionSet = questionSet
    }
    
    var selfUser: THUser!
    
    var awayUser: THUser!
    
    var completedAt: NSDate! {
        if isGameCompletedByBothPlayer {
            let date1 = initiatingPlayerResult.submittedAt
            let date2 = opponentPlayerResult.submittedAt
            if date1.compare(date2) == .OrderedAscending {
                return date2
            } else {
                return date1
            }
        }
        return nil
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
        
        if let exp: AnyObject = gameDTO["expired"] {
            self.expired = (exp as NSNumber).boolValue
        }
        
        if let rej: AnyObject = gameDTO["rejectedByOpponent"] {
            self.rejectedByOpponent = (rej as NSNumber).boolValue
        }
    }
    
    func populateResult(resultsDTO:[String : AnyObject]) {
        var challengerResult:GameResult?
        var opponentResult:GameResult?
        
        let inner: AnyObject? = resultsDTO["result"]
        if let innerResultDTO = inner as? [String : AnyObject] {
            if let challengerResultDTO: AnyObject = innerResultDTO["challenger"] {
                let dto = challengerResultDTO as [String : AnyObject]
                challengerResult = GameResult(gameId:self.gameID, resultDTO: dto)
            }
            if let opponentResultDTO: AnyObject = innerResultDTO["opponent"] {
                let dto = opponentResultDTO as [String : AnyObject]
                opponentResult = GameResult(gameId:self.gameID, resultDTO: dto)
            }
        }
        
        
        if let cResults = challengerResult {
            if self.initiatingPlayerID == cResults.userId {
                self.initiatingPlayerResult = cResults
            } else {
                self.opponentPlayerResult = cResults
            }
        }
        
        if let oResults = opponentResult {
            if self.opponentPlayerID == oResults.userId {
                self.opponentPlayerResult = oResults
            } else {
                self.initiatingPlayerResult = oResults
            }
        }
    }
    
    init(compactGameDTO:[String: AnyObject]){
        if let cuid: AnyObject = compactGameDTO["createdByUserId"] {
            self.initiatingPlayerID = cuid as Int
        }
        
        if let opuid: AnyObject = compactGameDTO["opponentUserId"] {
            self.opponentPlayerID = opuid as Int
        }
        
        var gameId: Int!
        if let id: AnyObject = compactGameDTO["id"] {
            self.gameID = id as Int
            gameId = id as Int
        }
        
        if let s: AnyObject = compactGameDTO["createdAtUtc"] {
            self.createdAtUTCStr = s as String
        }
        
        self.questionSet = nil
        
        if let rs: AnyObject = compactGameDTO["GameResults"] {
            if let resultsDTO = rs as? [String : AnyObject] {
                populateResult(resultsDTO)
            }
        }
        
        if let exp: AnyObject = compactGameDTO["expired"] {
            self.expired = (exp as NSNumber).boolValue
        }
        
        if let rej: AnyObject = compactGameDTO["rejectedByOpponent"] {
            self.rejectedByOpponent = (rej as NSNumber).boolValue
        }
        
        if let lnoau: AnyObject = compactGameDTO["lastNudgedOpponentAtUtc"] {
            self.lastNudgedOpponentAtUTCStr = lnoau as String
        }
    }
    
    func fetchUsers(completionHandler:()->()) {
        
        var client = NetworkClient.sharedClient
        
        var counter = 0
        var partialCompletionHandler: () -> () = {
            [unowned self] in
            counter++
            if counter == 2 {
                if client.user.userId == self.opponentPlayer.userId {
                    self.selfUser = self.opponentPlayer
                    self.awayUser = self.initiatingPlayer
                } else if client.user.userId == self.initiatingPlayer.userId {
                    self.selfUser = self.initiatingPlayer
                    self.awayUser = self.opponentPlayer
                }
                completionHandler()
            }
        }
        
        if initiatingPlayerID == NetworkClient.sharedClient.user.userId {
            client.fetchUser(opponentPlayerID, force: false, errorHandler:{error in debugPrintln(error)}) {
                [unowned self] in
                if let u = $0 {
                    self.opponentPlayer = u
                }
                partialCompletionHandler()
            }
            self.initiatingPlayer =  NetworkClient.sharedClient.user
            partialCompletionHandler()
        } else if opponentPlayerID == NetworkClient.sharedClient.user.userId {
            client.fetchUser(initiatingPlayerID, force: false, errorHandler:{error in debugPrintln(error)}) {
                [unowned self] in
                if let u = $0 {
                    self.initiatingPlayer = u
                }
                partialCompletionHandler()
            }
            self.opponentPlayer =  NetworkClient.sharedClient.user
            partialCompletionHandler()
        } else {
            client.fetchUser(initiatingPlayerID, force: false, errorHandler:{error in debugPrintln(error)}) {
                [unowned self] in
                if let u = $0 {
                    self.initiatingPlayer = u
                }
                partialCompletionHandler()
            }
            client.fetchUser(opponentPlayerID, force: false, errorHandler:{error in debugPrintln(error)}) {
                [unowned self] in
                if let u = $0 {
                    self.opponentPlayer = u
                }
                partialCompletionHandler()
            }
        }
        
        
    }
    
    func fetchResults(completionHandler:()->()){
        
        NetworkClient.sharedClient.getResultForGame(self.gameID, errorHandler:{error in debugPrintln(error)}) {
            [unowned self] in
            if let cResults = $0.challengerResult {
                if self.initiatingPlayer.userId == cResults.userId {
                    self.initiatingPlayerResult = cResults
                } else {
                    self.opponentPlayerResult = cResults
                }
            }
            if let oResults = $0.opponentResult {
                if self.opponentPlayer.userId == oResults.userId {
                    self.opponentPlayerResult = oResults
                } else {
                    self.initiatingPlayerResult = oResults
                }
            }
            
            completionHandler()
        }
    }
    
    func selfPlayerForGame(userId:Int) -> THUser!{
        if userId == self.initiatingPlayerID {
            return self.initiatingPlayer
        } else if userId == self.opponentPlayerID {
            return self.opponentPlayer
        }
        
        return nil
    }
    
    func opponentPlayerForGame(user:THUser) -> THUser! {
        if user.userId == self.initiatingPlayerID {
            return self.opponentPlayer
        } else if user.userId == self.opponentPlayerID {
            return self.initiatingPlayer
        }
        
        return nil
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
        if let qs = questionSet {
            for q in qs {
                d += "Question \(++i): \(q)"
            }
        }
            d += "\n}\n"
            return d
    }
}