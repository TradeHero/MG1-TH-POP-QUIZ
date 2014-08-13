//
//  GamePortfolio.swift
//  TradeGame
//
//  Created by Ryne Cheow on 8/8/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class GamePortfolio {
    
    let gamePortfolioID: Int!
    let rank: String!
    var IGN: String!
    var avatar: String!
    
    init(gamePfID: Int, rank: String) {
        self.gamePortfolioID = gamePfID
        self.rank = rank
    }
    
    
}
