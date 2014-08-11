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
    public let initiatingPlayer:GamePortfolio
    public let opponentPlayer:GamePortfolio
    
    public init(id: Int, initiator:GamePortfolio, opponent:GamePortfolio) {
        gameID = id
        initiatingPlayer = initiator
        opponentPlayer = opponent
    }
}
