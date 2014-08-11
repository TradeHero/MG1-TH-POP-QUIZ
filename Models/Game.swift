//
//  Game.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/7/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

public class Game {

    public let gameID: Int
    public let initiatingPlayer: THUser
    public let opponentPlayer: THUser
    public let createdAt: NSDate
    public let questionSet: [Question]
    
    public init(id: Int, initiator:THUser, opponent:THUser, createdAtUTC:NSDate, questionSet:[Question]) {
        self.gameID = id
        self.initiatingPlayer = initiator
        self.opponentPlayer = opponent
        self.createdAt = createdAtUTC
        self.questionSet = questionSet
        
    }
//    public let initiatingPlayer:GamePortfolio
//    public let opponentPlayer:GamePortfolio
//    public init(id: Int, initiator:GamePortfolio, opponent:GamePortfolio) {
//        gameID = id
//        initiatingPlayer = initiator
//        opponentPlayer = opponent
//    }
}
