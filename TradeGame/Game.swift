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

    var initiatingPlayer: THUser!

    var opponentPlayer: THUser!
    
    lazy var createdAt: NSDate! = {
        let df = NSDateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        df.timeZone = NSTimeZone(name: "UTC")
        return df.dateFromString(self.createdAtUTCStr)
    }()

    let questionSet: [Question]!
    
    init(id: Int, initPlayerID:Int, oppPlayerID:Int, createdAtUTCStr:String, questionSet:[Question]) {
        self.gameID = id
        self.createdAtUTCStr = createdAtUTCStr
        self.questionSet = questionSet
        NetworkClient.sharedClient.fetchUser(oppPlayerID) {
            user in
                if let u = user {
                    self.opponentPlayer = u
                }
            }
        NetworkClient.sharedClient.fetchUser(initPlayerID) {
            user in
                if let u = user {
                    self.initiatingPlayer = u
                }
            }
    }

    func fullyLoaded() -> Bool {
        return initiatingPlayer != nil && opponentPlayer != nil && createdAt != nil && questionSet != nil && gameID != nil
    }
}
