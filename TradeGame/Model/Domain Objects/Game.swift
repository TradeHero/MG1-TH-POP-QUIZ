//
//  Game.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/7/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class Game {
    
    let gameID: Int!
    private let createdAtUTCStr: String!

    var initiatingPlayer: THUser?

    var opponentPlayer: THUser?
    
    lazy var createdAt: NSDate! = {
        let df = NSDateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        df.timeZone = NSTimeZone(name: "UTC")
        return df.dateFromString(self.createdAtUTCStr)
    }()

    let questionSet: [Question]!
    
    init(id: Int, createdAtUTCStr:String, questionSet:[Question]) {
        self.gameID = id
        self.createdAtUTCStr = createdAtUTCStr
        self.questionSet = questionSet
    }

    init(gameDTO:[String: AnyObject]){
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
}

extension Game: Printable {
    var description : String {
        var d = "{\nGame details:\n"
            d += "ID: \(gameID)\n"
            d += "Created At: \(createdAt)\n"
            d += "Initiator: \(initiatingPlayer!)\n"
            d += "Opponent: \(opponentPlayer!)\n"
            d += "Questions: "
            var i:Int = 0
            for q in questionSet {
                d += "Question \(++i): \(q)"
            }
            d += "\n}\n"
            return d
    }
}